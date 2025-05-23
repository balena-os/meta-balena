/*
 * Copyright 2021 balena
 *
 * @license Apache-2.0
 */

'use strict';

const fs = require('fs');
const fse = require('fs-extra');
const { join, basename } = require('path');
const { homedir } = require('os');
const util = require('util');
const zlib = require('zlib');

const imagefs = require('balena-image-fs');
const stream = require('stream');
const { attempt } = require('bluebird');
const pipeline = util.promisify(stream.pipeline);

// copied from the SV
// https://github.com/balena-os/balena-supervisor/blob/master/src/config/backends/config-txt.ts
// TODO: retrieve this from the SDK (requires v16.2.0) or future versions of device contracts
// https://www.balena.io/docs/reference/sdk/node-sdk/#balena.models.config.getConfigVarSchema
const supportsBootConfig = (deviceType) => {
	return (
		[
			'fincm3',
			'rt-rpi-300',
			'243390-rpi3',
			'nebra-hnt',
			'revpi-connect',
			'revpi-core-3',
		].includes(deviceType) || deviceType.startsWith('raspberry')
	);
};

const flasherConfig = (deviceType) => {
	return (
		[
			'imx8mmebcrs08a2',
			'imx8mm-var-dart-plt',
		].includes(deviceType)
	);
}

const externalAnt = (deviceType) => {
	return (
		[
			'revpi-connect-4'
		]
	).includes(deviceType)
}

const checkUnderVoltage = async (that, test) => {
	test.comment(`checking for under-voltage reports in kernel logs...`);
	let result = '';
	result = await that.worker.executeCommandInHostOS(
		`dmesg | grep -q "Under-voltage detected" ; echo $?`,
		that.link,
	);

	if (result.includes('0')) {
		test.comment(`not ok! - Under-voltage detected on device, please check power source and cable!`);
	} else {
		test.comment(`ok - No under-voltage reports in the kernel logs`);
	}
};


const enableSerialConsole = async (imagePath) => {
	const bootConfig = await imagefs.interact(imagePath, 1, async (_fs) => {
		return util
			.promisify(_fs.readFile)('/config.txt')
			.catch((err) => {
				return undefined;
			});
	});

	if (bootConfig) {
		await imagefs.interact(imagePath, 1, async (_fs) => {
			const regex = /^enable_uart=.*$/m;
			const value = 'enable_uart=1';

			console.log(`Setting ${value} in config.txt...`);

			// delete any existing instances before appending to the file
			const newConfig = bootConfig.toString().replace(regex, '');
			await util.promisify(_fs.writeFile)(
				'/config.txt',
				newConfig.concat(`\n\n${value}\n\n`),
			);
		});
	}
};

// For device types that support it, this enables skipping boot switch selection, to simplify the automated flashing
const setFlasher = async(imagePath) => {
	await imagefs.interact(imagePath, 1, async (_fs) => {
		const value = 'resin_flasher_skip=0';

		console.log(`Setting ${value} in extra_uEnv.txt...`);

		await util.promisify(_fs.writeFile)(
			'/extra_uEnv.txt',
			`${value}\n\n`,
		);
	});
}

// For use with device types (e.g revpi connect 4) where an external antenna needs to be configured throuhg config.txt to work
const enableExternalAntenna  = async (imagePath) => {
	const bootConfig = await imagefs.interact(imagePath, 1, async (_fs) => {
		return util
			.promisify(_fs.readFile)('/config.txt')
			.catch((err) => {
				return undefined;
			});
	});

	if (bootConfig) {
		await imagefs.interact(imagePath, 1, async (_fs) => {
			const value = 'dtparam=ant2';

			console.log(`Setting ${value} in config.txt...`);

			await util.promisify(_fs.writeFile)(
				'/config.txt',
				bootConfig.toString().concat(`\n\n${value}\n\n`),
			);
		});
	}
};

// Executes the HUP process on the DUT
const doHUP = async (that, test, mode, target) => {
	const balenaHostTmpPath = "/mnt/sysroot/inactive/balena/tmp";
	const hupLoadTmp = "/mnt/data/resin-data/tmp";
	const inactiveStorage = "/mnt/sysroot/inactive/balena";

	await that.worker.executeCommandInHostOS(
		`systemctl stop balena-host`,
		target,
	);

	test.comment(`Cleaning up inactive partition`);
	await that.worker.executeCommandInHostOS(
		`find "${inactiveStorage}" -mindepth 1 -maxdepth 1 -exec rm -r "{}" \\; || true`,
		target,
	)

	await that.worker.executeCommandInHostOS(
		`systemctl start balena-host`,
		target,
	);

	test.comment(`Starting HUP`);

	let hupLog;
	switch (mode) {
		case 'local':
			if (
				(await that.worker.executeCommandInHostOS(
					`[[ -f ${that.hostappPath} ]] && echo exists`,
					target,
				)) !== 'exists'
			) {
				throw new Error(`Target image doesn't exists at location "${that.hostappPath}"`);
			}

			// bind mount the data partition for temporary extract & load files
			await that.worker.executeCommandInHostOS(
				`mkdir -p "${hupLoadTmp}" "${balenaHostTmpPath}" ; mount --bind "${hupLoadTmp}" "${balenaHostTmpPath}"`,
				target,
			);

			test.comment(`Running: hostapp-update -f ${that.hostappPath}`);
			hupLog = await that.worker.executeCommandInHostOS(`hostapp-update -f ${that.hostappPath}`, target);

			break;

		case 'image':
			test.comment(`Running: hostapp-update -i ${that.hupOs.image.path}`);
			hupLog = await that.worker.executeCommandInHostOS(`hostapp-update -i ${that.hupOs.image.path}`, target);
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

	if (supportsBootConfig(that.suite.deviceType.slug)) {
		await enableSerialConsole(that.os.image.path);
	}

	if(flasherConfig(that.suite.deviceType.slug)){
		await setFlasher(that.os.image.path);
	}

	if(externalAnt(that.suite.deviceType.slug)){
		await enableExternalAntenna(that.os.image.path);
	}


	test.comment(`Flashing DUT`);
	await that.worker.off();
	await that.worker.flash(that.os.image.path);
	await that.worker.on();

	await that.worker.addSSHKey(that.sshKeyPath);

	// create tunnels
	await test.resolves(
		that.worker.createSSHTunnels(
			that.link,
		),
		`Should detect ${that.link} on local network and establish tunnel`
	)

	await test.resolves(
		that.utils.waitUntil(async () => {
			return (
				(await that.worker.executeCommandInHostOS(
					'[[ -f /etc/hostname ]] && echo pass || echo fail',
					target,
				)) === 'pass'
			);
		}, true),
		`Device ${that.link} should be reachable over local SSH connection`
	)
	test.comment(`DUT flashed`);

	// Retrieving journalctl logs
	that.teardown.register(async () => {
		await that.worker.archiveLogs(
			that.id,
			that.link,
			"journalctl --no-pager --no-hostname --list-boots | awk '{print $1}' | xargs -I{} sh -c 'set -x; journalctl --no-pager --no-hostname -a -b {} || true;'",
		);
	});

	let hupOsName = basename(that.hupOs.image.path);
	console.log(hupOsName)

	// compress hostapp before sending
	test.comment('Compressing image...')
	let hostAppGzipped = `${that.hupOs.image.path}.gz`
	await pipeline(
		fs.createReadStream(that.hupOs.image.path),
		zlib.createGzip(),
		fs.createWriteStream(hostAppGzipped)
	);

	test.comment('Sending image to DUT');
	// send hostapp to DUT
	let attempts = 0;
	let sent = false;
	while(!sent){
		try{
			await that.worker.sendFile(hostAppGzipped, `/mnt/data/resin-data/`, target);
			console.log('Hostapp successfully sent!')
			sent = true
		}catch(e){
			if(attempts < 5){
				console.log(`Error while sending image... Retrying`);
				attempts++;
			} else {
				throw new Error (`Failed to send hostapp image to dut: ${e.message}`)
			}
		}
	}

	that.suite.context.set({ hostappPath: `/mnt/data/resin-data/${hupOsName}` })
	console.log(that.hostappPath);

	// unzip hostapp
	await that.worker.executeCommandInHostOS(
		`gzip -df ${that.hostappPath}.gz`,
		target,
	);
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
			sdk: new Balena(this.suite.options.balena.apiUrl, this.getLogger(), this.suite.options.config.sshConfig),
			sshKeyPath: join(homedir(), 'id'),
			sshKeyLabel: this.suite.options.id,
			link: `${this.suite.options.balenaOS.config.uuid.slice(0, 7)}.local`,
			worker: new Worker(this.suite.deviceType.slug,
				this.getLogger(),
				this.suite.options.workerUrl,
				this.suite.options.balena.organization,
				join(homedir(), 'id'),
				this.suite.options.config.sshConfig
			),
		});

		// Network definitions
		// If suites config.js has networkWired: true, override the device contract
		if (this.suite.options.balenaOS.network.wired === true) {
			this.suite.options.balenaOS.network.wired = {
				nat: true,
			};
		} else if(this.suite.deviceType.data.connectivity.wifi === false){
			// DUT has no wifi - use wired ethernet sharing to connect to DUT
			this.suite.options.balenaOS.network.wired = {
				nat: true,
			};
		}
		else {
			// device has wifi, use wifi hotspot to connect to DUT
			delete this.suite.options.balenaOS.network.wired;
		}

		// If suites config.js has networkWireless: true, override the device contract
		if (this.suite.options.balenaOS.network.wireless === true) {
			this.suite.options.balenaOS.network.wireless = {
				ssid: this.suite.options.id,
				psk: `${this.suite.options.id}_psk`,
				nat: true,
			};
		} else if(this.suite.deviceType.data.connectivity.wifi === true){
			// device has wifi, use wifi hotspot to connect to DUT
			this.suite.options.balenaOS.network.wireless = {
				ssid: this.suite.options.id,
				psk: `${this.suite.options.id}_psk`,
				nat: true,
			};
		}
		else {
			// no wifi on DUT
			delete this.suite.options.balenaOS.network.wireless;
		}

		this.suite.context.set({
			hup: {
				checkUnderVoltage: checkUnderVoltage,
				doHUP: doHUP,
				initDUT: initDUT,
			},
		});

		// Authenticating balenaSDK
		// Required for downloading private device type images from balenaCloud
		// the token is locally stored so a subsequent login with fetchOs will work, despite being a different sdk instance
		await this.context
		.get()
		.sdk.balena.auth.loginWithToken(this.suite.options.balena.apiKey);
		this.log(`Logged in with ${await (this.context.get().sdk.balena.auth.whoami()).username}'s account on ${this.suite.options.balena.apiUrl} using balenaSDK`);


		// Downloads the balenaOS image we hup from		
		// It can't accept invalid deviceType because we check contracts already in the start
		// If there are no releases found for a deviceType then skip the HUP suite
		if (((await this.sdk.balena.models.os.getAvailableOsVersions(this.suite.deviceType.slug)).length) === 0) {
			// Concat method not working so pushing one test suite at a time to skip
			// Also, can't access the tests object using `this.tests` to keep this from becoming hard-coded
			this.suite.options.debug.unstable.push('Rollback tests')
			this.suite.options.debug.unstable.push('Smoke tests')
			return
		}

		console.log('OS download options:')
		console.log(this.suite.options.balenaOS.download)
		let path = await this.sdk.fetchOS(
			this.suite.options.balenaOS.download.version,
			this.suite.deviceType.slug,
			this.suite.options.balenaOS.download.imageType
		);

		const keys = await this.utils.createSSHKey(this.sshKeyPath);

		await this.sdk.balena.models.key.create(
			this.sshKeyLabel,
			keys.pubKey
		);
		this.suite.teardown.register(() => {
			return Promise.resolve(
				this.sdk.removeSSHKey(this.sshKeyLabel)
			);
		});


		this.suite.context.set({
			workerContract: await this.worker.getContract()
		})

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
								keys.pubKey
							],
						},
						// persistentLogging is managed by the supervisor and only read at first boot
						persistentLogging: true,
						// Set local mode so we can perform local pushes of containers to the DUT
						localMode: true,
						developmentMode: true,
						installer: {
							secureboot: ['1', 'true'].includes(process.env.FLASHER_SECUREBOOT),
							migrate: { force: this.suite.options.balenaOS.config.installerForceMigration },
							whitelist_pcr2: true
						},
					},
				},
				this.getLogger(),
			),
			hupOs: new BalenaOS({}, this.getLogger()),
		});
		this.suite.teardown.register(() => {
			this.log('Worker teardown');
			return this.worker.teardown();
		});

		if ( this.workerContract.workerType === `qemu` && this.os.configJson.installer.migrate.force ) {
			console.log("Forcing installer migration")
		} else {
			console.log("No migration requested")
		}

		if ( this.os.configJson.installer.secureboot ) {
			console.log("Opting-in secure boot and full disk encryption")
		} else {
			console.log("No secure boot requested")
		}

		this.log('Setting up worker');
		await this.worker.network(this.suite.options.balenaOS.network);

		// Unpack both base and target OS images
		await this.os.fetch();
		await this.hupOs.fetch();
		// configure the image
		await this.os.configure();

		// Retrieving journalctl logs
		this.suite.teardown.register(async () => {
			await this.worker.archiveLogs(this.id, this.link);
		});
	},
	tests: [
		'./tests/rollbacks',
		'./tests/smoke',
	],
};
