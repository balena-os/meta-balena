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
const util = require('util');

// required for unwrapping images
const imagefs = require('balena-image-fs');
const stream = require('stream');
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

const externalAnt = (deviceType) => {
	return (
		[
			'revpi-connect-4'
		]
	).includes(deviceType)
}

const flasherConfig = (deviceType) => {
	return (
		[
			'imx8mmebcrs08a2',
			'imx8mm-var-dart-plt',
		].includes(deviceType)
	);
}

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

module.exports = {
	title: 'Unmanaged BalenaOS release suite',
	run: async function (test) {
		// The worker class contains methods to interact with the DUT, such as flashing, or executing a command on the device
		const Worker = this.require('common/worker');
		const Balena = this.require("components/balena/sdk");
		// The balenaOS class contains information on the OS image to be flashed, and methods to configure it
		const BalenaOS = this.require('components/os/balenaos');
		const utils = this.require('common/utils');
		const worker = new Worker(
			this.suite.deviceType.slug,
			this.getLogger(),
			this.suite.options.workerUrl,
			this.suite.options.balena.organization,
			join(homedir(), 'id'),
			this.suite.options.config.sshConfig
		);

		const cloud = new Balena(this.suite.options?.balena?.apiUrl, this.getLogger(), this.suite.options.config.sshConfig);

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
								`systemctl is-active ${serviceName} || true`,
								target,
							)
							.then((serviceStatus) => {
								return Promise.resolve(serviceStatus === state);
							})
							.catch((err) => {
								Promise.reject(err);
							});
					},
					false,
					120,
					250,
				);
			},
		};

		/**
		 * Write or remove a property from config.json in the boot partition
		 * @param {string} test Current test instance to append results
		 * @param {string} key Object key to update, dot separated
		 * @param {string} value New value, can be string, or object, or null|undefined to remove
		 * @param {string} target The address of the target device
		 *
		 * @category helper
		 */
		systemd.writeConfigJsonProp = async (test, key, value, target) => {

			return test.test(`Write or remove ${key} in config.json`, t =>
				t.resolves(
					systemd.waitForServiceState(
						'config-json.service',
						'inactive',
						target
					),
					'Should wait for config-json.service to be inactive'
				).then(() => {
					if (value == null) {
						return t.resolves(
							worker.executeCommandInHostOS(
								[
									`tmp=$(mktemp)`,
									`&&`, `jq`, `"del(.${key})"`, `/mnt/boot/config.json`,
									`>`, `$tmp`, `&&`, `mv`, `"$tmp"`, `/mnt/boot/config.json`
								].join(' '),
								target
							), `Should remove ${key} from config.json`
						)
					} else {
						if (typeof(value) == 'string') {
							value = `"${value}"`
						} else {
							value = JSON.stringify(value);
						}

						return t.resolves(
							worker.executeCommandInHostOS(
								[
									`tmp=$(mktemp)`,
									`&&`, `jq`, `'.${key}=${value}'`, `/mnt/boot/config.json`,
									`>`, `$tmp`, `&&`, `mv`, `"$tmp"`, `/mnt/boot/config.json`
								].join(' '),
								target
							), `Should write ${key} to ${value.substring(24) ? value.replace(value.substring(24), '...') : value} in config.json`
						)
					}
				}).then(() => {
					// avoid hitting 'start request repeated too quickly'
					return t.resolves(
						worker.executeCommandInHostOS(
							'systemctl reset-failed config-json.service',
							target
						), `Should reset start counter of config-json.service`
					);
				}).then(() => {
					return t.resolves(
						systemd.waitForServiceState(
							'config-json.service',
							'inactive',
							target
						),
						'Should wait for config-json.service to be inactive'
					)
				})
			);
		}

		// The suite contex is an object that is shared across all tests. Setting something into the context makes it accessible by every test
		this.suite.context.set({
			cloud: cloud,
			utils: utils,
			systemd: systemd,
			sshKeyPath: join(homedir(), 'id'),
			sshKeyLabel: this.suite.options.id,
			link: `${this.suite.options.balenaOS.config.uuid.slice(0, 7)}.local`,
			worker: worker,
		});

		// Network definitions - here we check what network configuration is selected for the DUT for the suite, and add the appropriate configuration options (e.g wifi credentials)
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


		const keys = await this.context
		.get()
		.utils.createSSHKey(this.sshKeyPath);
		// Create an instance of the balenOS object, containing information such as device type, and config.json options
		this.suite.context.set({
			os: new BalenaOS(
				{
					deviceType: this.suite.deviceType.slug,
					network: this.suite.options.balenaOS.network,
					configJson: {
						uuid: this.suite.options.balenaOS.config.uuid,
						os: {
              // Set a connectivity-check URI for HTTPS time sync service
              network: {
                connectivity: {
                  uri: 'https://api.balena-cloud.com/connectivity-check'
                }
              },
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
							// Note that QEMU needs to be configured with no internal storage
							migrate: { force: this.suite.options.balenaOS.config.installerForceMigration },
							whitelist_pcr2: true
						},
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
		await this.context
			.get()
			.worker.network(this.suite.options.balenaOS.network);


		this.suite.context.set({
			workerContract: await this.worker.getContract()
		})
		// Unpack OS image .gz
		await this.os.fetch();

		if (supportsBootConfig(this.suite.deviceType.slug)) {
			await enableSerialConsole(this.os.image.path);
		}

		if(flasherConfig(this.suite.deviceType.slug)){
			await setFlasher(this.os.image.path);
		}

		if(externalAnt(this.suite.deviceType.slug)){
			await enableExternalAntenna(this.os.image.path);
		}

		if (this.suite.options?.balena?.apiKey) {
			// Authenticating balenaSDK
			await this.context
			.get()
			.cloud.balena.auth.loginWithToken(this.suite.options.balena.apiKey);
			this.log(`Logged in with ${await (this.context.get().cloud.balena.auth.whoami()).username}'s account on ${this.suite.options.balena.apiUrl} using balenaSDK`);

			console.log(await (this.context.get().cloud.balena.auth.whoami()))

			await this.cloud.balena.models.key.create(
				this.sshKeyLabel,
				keys.pubKey
			);
			this.suite.teardown.register(() => {
				return Promise.resolve(
					this.cloud.removeSSHKey(this.sshKeyLabel)
				);
			});
		}

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

		// Configure OS image
		await this.os.configure();

		// Flash the DUT
		await this.worker.off(); // Ensure DUT is off before starting tests
		await this.worker.flash(this.os.image.path);
		await this.worker.on();

		await this.worker.addSSHKey(this.sshKeyPath);

		// create tunnels
		await test.resolves(
			this.worker.createSSHTunnels(
				this.link,
			),
			`Should detect ${this.link} on local network and establish tunnel`
		)

		await test.resolves(
			this.utils.waitUntil(async () => {
				let hostname = await this.worker.executeCommandInHostOS(
				"cat /etc/hostname",
				this.link
				)
				return (hostname === this.link.split('.')[0])
			}, true),
			`Device ${this.link} should be reachable over local SSH connection`
		)

		await test.resolves(
			systemd.waitForServiceState('balena', 'active', this.link),
			'balena Engine should be running and healthy'
		)

		// we want to waitUntil here as the supervisor may take some time to come online.
		await test.resolves(
			this.utils.waitUntil(async () => {
				let healthy = await this.worker.executeCommandInHostOS(
				`curl --max-time 10 "localhost:48484/v1/healthy"`,
				this.link
				)
				return (healthy === 'OK')
			}, true, 120, 250),
			'Supervisor should be running and healthy'
		)


		// Retrieving journalctl logs: register teardown after device is reachable
		this.suite.teardown.register(async () => {
			await this.context
				.get()
				.worker.archiveLogs(this.id, this.link);
		});
	},
	tests: [
		'./tests/secureboot',
		'./tests/device-specific-tests/beaglebone-black',
		'./tests/device-specific-tests/243390-rpi3',
		'./tests/power-and-cooling',
		'./tests/overlap_test/',
		'./tests/fingerprint',
		'./tests/fsck',
		'./tests/os-release',
		'./tests/iptables',
		'./tests/migrate',
		'./tests/issue',
		'./tests/chrony',
		'./tests/kernel-overlap',
		'./tests/bluetooth',
		'./tests/container-healthcheck',
		'./tests/variables',
		'./tests/led',
		'./tests/modem',
		'./tests/config-json',
		'./tests/boot-splash',
		'./tests/connectivity',
		'./tests/engine-socket',
		'./tests/engine-healthcheck',
		'./tests/under-voltage',
		'./tests/regulatory-db',
		'./tests/udev',
		'./tests/device-tree',
		'./tests/purge-data',
		'./tests/device-specific-tests/revpi-core-3',
		'./tests/swap',
		'./tests/internet-sharing',
		'./tests/safe-reboot',
	],
};
