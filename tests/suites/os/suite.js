/*
 * Copyright 2018 balena
 *
 * @license Apache-2.0
 */

'use strict';

const assert = require('assert');
const fse = require('fs-extra');
const { join } = require('path');
const { homedir } = require('os');

// required for unwrapping images
const imagefs = require('balena-image-fs');
const stream = require('stream');
const pipeline = require('bluebird').promisify(stream.pipeline);

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

const enableSerialConsole = async (imagePath) => {
	const bootConfig = await imagefs.interact(imagePath, 1, async (_fs) => {
		return require('bluebird')
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
			await require('bluebird').promisify(_fs.writeFile)(
				'/config.txt',
				newConfig.concat(`\n\n${value}\n\n`),
			);
		});
	}
};

module.exports = {
	title: 'Unmanaged BalenaOS release suite',
	run: async function (test) {
		// The worker class contains methods to interact with the DUT, such as flashing, or executing a command on the device
		const Worker = this.require('common/worker');
		// The balenaOS class contains information on the OS image to be flashed, and methods to configure it
		const BalenaOS = this.require('components/os/balenaos');
		const utils = this.require('common/utils');
		const worker = new Worker(this.suite.deviceType.slug, this.getLogger());

		await fse.ensureDir(this.suite.options.tmpdir);

		let systemd = {
			/**
			 * Wait for a service to be active/inactive
			 * @param {string} serviceName systemd service to query and wait for
			 * @param {string} state active|inactive
			 * @param {string} target the address of the device to query
			 *
			 * @category helper
			 */
			waitForServiceState: async function (serviceName, state, target) {
				return utils.waitUntil(
					async () => {
						return worker
							.executeCommandInHostOS(
								`systemctl is-active ${serviceName}`,
								target,
							)
							.then((serviceStatus) => {
								return Promise.resolve(serviceStatus === state);
							})
							.catch((err) => {
								Promise.reject(err);
							});
					},
					120,
					250,
				);
			},
		};

		// The suite contex is an object that is shared across all tests. Setting something into the context makes it accessible by every test
		this.suite.context.set({
			utils: utils,
			systemd: systemd,
			sshKeyPath: join(homedir(), 'id'),
			link: `${this.suite.options.balenaOS.config.uuid.slice(0, 7)}.local`,
			worker: worker,
		});

		// Network definitions - here we check what network configuration is selected for the DUT for the suite, and add the appropriate configuration options (e.g wifi credentials)
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

		// Create an instance of the balenOS object, containing information such as device type, and config.json options
		this.suite.context.set({
			os: new BalenaOS(
				{
					deviceType: this.suite.deviceType.slug,
					network: this.suite.options.balenaOS.network,
					configJson: {
						uuid: this.suite.options.balenaOS.config.uuid,
						os: {
							sshKeys: [
								await this.utils.createSSHKey(this.sshKeyPath),
							],
						},
						// Set an API endpoint for the HTTPS time sync service.
						apiEndpoint: 'https://api.balena-cloud.com',
						// persistentLogging is managed by the supervisor and only read at first boot
						persistentLogging: true,
						// Set local mode so we can perform local pushes of containers to the DUT
						localMode: true,
						developmentMode: true,
					},
				},
				this.getLogger(),
			),
		});

		// Register a teardown function execute at the end of the test, regardless of a pass or fail
		this.suite.teardown.register(() => {
			this.log('Worker teardown');
			return this.worker.teardown();
		});

		this.log('Setting up worker');

		// Create network AP on testbot
		await this.worker.network(this.suite.options.balenaOS.network);

		// Unpack OS image .gz
		await this.os.fetch();

		// If this is a flasher image, and we are using qemu, unwrap
		if (
			this.suite.deviceType.data.storage.internal &&
			process.env.WORKER_TYPE === `qemu`
		) {
			const RAW_IMAGE_PATH = `/opt/balena-image-${this.suite.deviceType.slug}.balenaos-img`;
			const OUTPUT_IMG_PATH = '/data/downloads/unwrapped.img';
			console.log(`Unwrapping file ${this.os.image.path}`);
			console.log(`Looking for ${RAW_IMAGE_PATH}`);
			try {
				await imagefs.interact(
					this.os.image.path,
					2,
					async (fsImg) => {
						await pipeline(
							fsImg.createReadStream(RAW_IMAGE_PATH),
							fse.createWriteStream(OUTPUT_IMG_PATH),
						);
					},
				);

				this.os.image.path = OUTPUT_IMG_PATH;
				console.log(`Unwrapped flasher image!`);
			} catch (e) {
				// If the outer image doesn't contain an image for installation, ignore the error
				if (e.code === 'ENOENT') {
					console.log('Not a flasher image, skipping unwrap');
				} else {
					throw e;
				}
			}
		}

		if (supportsBootConfig(this.suite.deviceType.slug)) {
			await enableSerialConsole(this.os.image.path);
		}

		// Configure OS image
		await this.os.configure();

		// Flash the DUT
		await this.worker.off(); // Ensure DUT is off before starting tests
		await this.worker.flash(this.os.image.path);
		await this.worker.on();

		this.log('Waiting for device to be reachable');
		assert.equal(
			await this.worker.executeCommandInHostOS(
					'cat /etc/hostname',
					this.link,
				),
			this.link.split('.')[0],
			'Device should be reachable',
		);

		// Retrieving journalctl logs: register teardown after device is reachable
		this.suite.teardown.register(async () => {
			await this.worker.archiveLogs(this.id, this.link);
		});
	},
	tests: [
		'./tests/device-specific-tests/beaglebone-black',
		'./tests/fingerprint',
		'./tests/fsck',
		'./tests/os-release',
		'./tests/issue',
		'./tests/chrony',
		'./tests/kernel-overlap',
		'./tests/bluetooth',
		'./tests/healthcheck',
		'./tests/variables',
		'./tests/led',
		'./tests/config-json',
		'./tests/boot-splash',
		'./tests/connectivity',
		'./tests/engine-socket',
		'./tests/under-voltage',
		'./tests/udev',
		'./tests/device-tree',
		'./tests/purge-data',
		'./tests/device-specific-tests/revpi-core-3',
	],
};
