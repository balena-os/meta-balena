/*
 * Copyright 2021 balena
 *
 * @license Apache-2.0
 */

'use strict';

const fs = require('fs');
const fse = require('fs-extra');
const { join } = require('path');
const { homedir } = require('os');
const Docker = require('dockerode');

// required for unwrapping images
const imagefs = require('balena-image-fs');
const stream = require('stream');
const pipeline = require('bluebird').promisify(stream.pipeline);

// required to use skopeo for loading the image
const exec = require('bluebird').promisify(require('child_process').exec);

// Starts registry, uploads target image to registry
const runRegistry = async (that, test, seedWithImage) => {
	const docker = new Docker();
	const ip = await that.context.get().worker.ip(that.context.get().link);

	test.comment('Starting registry...');
	await that.context
		.get()
		.worker.pushContainerToDUT(
			ip,
			require('path').join(__dirname, 'assets'),
			'registry',
		);

	test.comment('Loading hostapp image into registry...');
	const ref = `${ip}:5000/hostapp`;

	await exec(
		`skopeo copy --dest-tls-verify=false docker-archive://${seedWithImage} docker://${ref}`,
	);
	const hostappRef = await exec(
		`skopeo inspect --tls-verify=false docker://${ref}`,
	).then((out) => {
		const json = JSON.parse(out);
		// we use ${ip}:5000/hostapp in the suite to push the hostapp to the
		// registry, but `hostappRef` is what we tell the DUT to HUP to.
		// Since balenaEngine on the DUT will also require special setup to allow
		// pulling from an insecure registry, we pass along a localhost ref
		// which docker accepts by default
		//
		// TODO the alternative would be to push the image directly into the daemon using:
		// skopeo copy docker-archive://tarball docker-daemon://${ip}:2376/hostapp
		// Figure out if the DUT docker daemon is exposed...
		return `localhost:5000/hostapp@${json.Digest}`;
	});

	test.comment(`Registry upload complete: ${ref}`);

	that.suite.context.set({
		hup: {
			payload: hostappRef,
		},
	});
};

// Executes the HUP process on the DUT
const doHUP = async (that, test, mode, hostapp, target) => {
	test.comment(`Starting HUP`);

	let hupLog;
	switch (mode) {
		case 'local':
			if (
				(await that.context
					.get()
					.worker.executeCommandInHostOS(
						`[[ -f ${hostapp} ]] && echo exists`,
						target,
					)) !== 'exists'
			) {
				throw new Error(`Target image doesn't exists at location "${hostapp}"`);
			}
			test.comment(`Running: hostapp-update -f ${hostapp}`);
			hupLog = await that.context
				.get()
				.worker.executeCommandInHostOS(`hostapp-update -f ${hostapp}`, target);
			break;

		case 'image':
			test.comment(`Running: hostapp-update -i ${hostapp}`);
			hupLog = await that.context
				.get()
				.worker.executeCommandInHostOS(`hostapp-update -i ${hostapp}`, target);
			break;

		default:
			throw new Error(`Unsupported HUP mode: ${mode}`);
	}

	const hupLogPath = join(that.suite.options.tmpdir, `hup.log`);
	fs.writeFileSync(hupLogPath, hupLog);
	await that.archiver.add(that.id, hupLogPath);

	test.comment(`Finished HUP`);
};

const initDUT = async (that, test, target) => {
	test.comment(`Initializing DUT for HUP test`);

	test.comment(`Flashing DUT`);
	await that.context.get().worker.off();
	await that.context.get().worker.flash(that.context.get().os.image.path);
	await that.context.get().worker.on();

	test.comment(`Waiting for DUT to be reachable`);
	await that.context.get().utils.waitUntil(async () => {
		return (
			(await that.context
				.get()
				.worker.executeCommandInHostOS(
					'[[ -f /etc/hostname ]] && echo pass || echo fail',
					target,
				)) === 'pass'
		);
	}, true);
	test.comment(`DUT flashed`);

	// Starts the registry and pushes the hostapp
	await runRegistry(that, test, that.context.get().hupOs.image.path);

	// Retrieving journalctl logs
	that.teardown.register(async () => {
		await that.context
			.get()
			.worker.archiveLogs(
				that.id,
				that.context.get().link,
				"journalctl --no-pager --no-hostname --list-boots | awk '{print $1}' | xargs -I{} sh -c 'set -x; journalctl --no-pager --no-hostname -a -b {} || true;'",
			);
	});
};

module.exports = {
	title: 'Hostapp update suite',

	run: async function () {
		const Worker = this.require('common/worker');
		const BalenaOS = this.require('components/os/balenaos');
		const Balena = this.require('components/balena/sdk');

		await fse.ensureDir(this.suite.options.tmpdir);

		this.suite.context.set({
			utils: this.require('common/utils'),
			sdk: new Balena(this.suite.options.balena.apiUrl, this.getLogger()),
			sshKeyPath: join(homedir(), 'id'),
			link: `${this.suite.options.balenaOS.config.uuid.slice(0, 7)}.local`,
			worker: new Worker(this.suite.deviceType.slug, this.getLogger()),
		});

		// Network definitions
		if (this.suite.options.balenaOS.network.wired === true) {
			this.suite.options.balenaOS.network.wired = {
				nat: true,
			};
		} else {
			delete this.suite.options.balenaOS.network.wired;
		}
		if (this.suite.options.balenaOS.network.wireless === true) {
			this.suite.options.balenaOS.network.wireless = {
				ssid: this.suite.options.id,
				psk: `${this.suite.options.id}_psk`,
				nat: true,
			};
		} else {
			delete this.suite.options.balenaOS.network.wireless;
		}

		this.suite.context.set({
			hup: {
				doHUP: doHUP,
				initDUT: initDUT,
				runRegistry: runRegistry,
			},
		});

		// Downloads the balenaOS image we hup from
		let path = await this.context
			.get()
			.sdk.fetchOS(
				this.suite.options.balenaOS.download.version,
				this.suite.deviceType.slug,
			);

		// if we are running qemu, and the device type is a flasher image, we need to unpack it from the flasher image to get it to boot
		if (
			this.suite.deviceType.data.storage.internal &&
			process.env.WORKER_TYPE === `qemu`
		) {
			const RAW_IMAGE_PATH = `/opt/balena-image-${this.suite.deviceType.slug}.balenaos-img`;
			const OUTPUT_IMG_PATH = '/data/downloads/unwrapped.img';
			console.log(`Unwrapping flasher image ${path}`);
			await imagefs.interact(path, 2, async (fsImg) => {
				await pipeline(
					fsImg.createReadStream(RAW_IMAGE_PATH),
					fs.createWriteStream(OUTPUT_IMG_PATH),
				);
			});
			path = OUTPUT_IMG_PATH;
			console.log(`Unwrapped flasher image!`);
		}

		this.suite.context.set({
			os: new BalenaOS(
				{
					deviceType: this.suite.deviceType.slug,
					network: this.suite.options.balenaOS.network,
					image: `${path}`,
					configJson: {
						uuid: this.suite.options.balenaOS.config.uuid,
						os: {
							sshKeys: [
								await this.context
									.get()
									.utils.createSSHKey(this.context.get().sshKeyPath),
							],
						},
						// persistentLogging is managed by the supervisor and only read at first boot
						persistentLogging: true,
						// Set local mode so we can perform local pushes of containers to the DUT
						localMode: true,
						developmentMode: true,
					},
				},
				this.getLogger(),
			),
			hupOs: new BalenaOS({}, this.getLogger()),
		});
		this.suite.teardown.register(() => {
			this.log('Worker teardown');
			return this.context.get().worker.teardown();
		});

		this.log('Setting up worker');
		await this.context
			.get()
			.worker.network(this.suite.options.balenaOS.network);

		// Unpack both base and target OS images
		await this.context.get().os.fetch();
		await this.context.get().hupOs.fetch();
		// configure the image
		await this.context.get().os.configure();

		// Retrieving journalctl logs
		this.suite.teardown.register(async () => {
			await this.context
				.get()
				.worker.archiveLogs(this.id, this.context.get().link);
		});
	},
	tests: [
		'./tests/smoke',
		'./tests/rollback-altboot',
		'./tests/rollback-health',
	],
};
