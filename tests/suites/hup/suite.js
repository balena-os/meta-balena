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
const exec = require('bluebird').promisify(require('child_process').exec);
const Bluebird = require('bluebird');

// Starts registry, uploads target image to registry
const runRegistry = async (that, seedWithImage) => {
	const docker = new Docker();
	const ip = await that.context.get().worker.ip(that.context.get().link);

	that.log('Starting registry...');
	const state = await that.context.get()
		.worker.pushContainerToDUT(ip, require('path').join(__dirname, 'assets'), 'registry');
		that.log(state);

	that.log('Loading hostapp image to context...');
	const imageName = await docker
		.loadImage(seedWithImage)
		.then(res => {
			return new Promise((resolve, reject) => {
				var bufs = [];
				res.on('error', err => reject(err));
				res.on('data', data => bufs.push(data));
				res.on('end', () => resolve(JSON.parse(Buffer.concat(bufs))));
			});
		})
		.then(json => {
			const str = json.stream.split('Loaded image ID: ');
			if (str.length === 2) {
				return str[1].trim();
			}
			throw new Error('failed to parse image name from loadImage stream');
		});

	const image = await docker.getImage(imageName);
	const ref = `${ip}:5000/hostapp`;

	await image.tag({ repo: ref, tag: 'latest' });
	const tagged = await docker.getImage(ref);

	that.log('Pushing hostapp image to registry...');
	const digest = await tagged
		.push({ ref })
		.then(res => {
			return new Promise((resolve, reject) => {
				var bufs = [];
				res.on('error', err => reject(err));
				res.on('data', data => bufs.push(JSON.parse(data)));
				res.on('end', () => resolve(bufs));
			});
		})
		.then(output => {
			for (let json of output) {
				if (json.error) {
					throw new Error(json.error);
				}
				if (json.aux && json.aux.Digest) {
					return json.aux.Digest;
				}
			}
			throw new Error('no digest');
		});
	await image.remove();

	// does it work as localhost?
	const hostappRef = `${ref}@${digest}`;
	that.log(`Registry upload complete: ${hostappRef}`);

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
	await runRegistry(that, that.context.get().hupOs.image.path);

	// Retrieving journalctl logs
	that.teardown.register(async () => {
		await that.context.get().worker.archiveLogs(that.id, that.context.get().link, "journalctl --no-pager --no-hostname --list-boots | awk '{print $1}' | xargs -I{} sh -c 'set -x; journalctl --no-pager --no-hostname -a -b {} || true;'");
	});
};

module.exports = {
	title: 'Hostapp update suite',

	run: async function() {
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
				runRegistry: runRegistry
			},
		});

		// Downloads the balenaOS image we hup from
		const path = await this.context
			.get()
			.sdk.fetchOS(
				this.suite.options.balenaOS.download.version,
				this.suite.deviceType.slug,
			);

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
	},
	tests: [
		'./tests/smoke',
		'./tests/rollback-altboot',
		'./tests/rollback-health',
	],
};
