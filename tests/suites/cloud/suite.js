/*
 * Copyright 2018 balena
 *
 * @license Apache-2.0
 */

"use strict";

const fse = require("fs-extra");
const { join } = require("path");
const { homedir } = require("os");
const util = require('util');
const exec = util.promisify(require('child_process').exec);

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

const enableSerialConsole = async (imagePath) => {
	const bootConfig = await imagefs.interact(imagePath, 1, async (_fs) => {
		return util.promisify(_fs.readFile)('/config.txt')
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
  title: "Managed BalenaOS release suite",
  run: async function (test) {
    const Worker = this.require("common/worker");
    const BalenaOS = this.require("components/os/balenaos");
    const Balena = this.require("components/balena/sdk");
    // used for `preload`
    const CLI = this.require("components/balena/cli");
    const utils = this.require('common/utils');

    await fse.ensureDir(this.suite.options.tmpdir);

    // add objects to the context, so that they can be used across all the tests in this suite
    this.suite.context.set({
      cloud: new Balena(this.suite.options.balena.apiUrl, this.getLogger(), this.suite.options.config.sshConfig),
      balena: {
        name: this.suite.options.id,
        organization: this.suite.options.balena.organization,
        sshKey: { label: this.suite.options.id },
      },
      cli: new CLI(this.suite.options.balena.apiUrl, this.getLogger()),
      sshKeyPath: join(homedir(), "id"),
      utils: this.require("common/utils"),
      worker: new Worker(
        this.suite.deviceType.slug,
        this.getLogger(),
        this.suite.options.workerUrl,
        this.suite.options.balena.organization,
        join(homedir(), 'id'),
        this.suite.options.config.sshConfig
      ),
      waitForServiceState: async function (serviceName, state, target) {
        return utils.waitUntil(
          async () => {
            return this.worker
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
          120,
          250,
        );
      },
      /**
		 * Write or remove a property from config.json in the boot partition
		 * @param {string} test Current test instance to append results
		 * @param {string} key Object key to update, dot separated
		 * @param {string} value New value, can be string, or object, or null|undefined to remove
		 * @param {string} target The address of the target device
		 *
		 * @category helper
		 */
		writeConfigJsonProp: async function (test, key, value, target) {

			return test.test(`Write or remove ${key} in config.json`, t =>
				t.resolves(
					this.waitForServiceState(
						'config-json.service',
						'inactive',
						target
					),
					'Should wait for config-json.service to be inactive'
				).then(() => {
					if (value == null) {
						return t.resolves(
							this.worker.executeCommandInHostOS(
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
							this.worker.executeCommandInHostOS(
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
						this.worker.executeCommandInHostOS(
							'systemctl reset-failed config-json.service',
							target
						), `Should reset start counter of config-json.service`
					);
				}).then(() => {
					return t.resolves(
						this.waitForServiceState(
							'config-json.service',
							'inactive',
							target
						),
						'Should wait for config-json.service to be inactive'
					)
				})
			);
		}
    });

    // Network definitions - these are given to the testbot via the config sent via the config.js
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

    // Authenticating balenaSDK
    await this.context
    .get()
    .cloud.balena.auth.loginWithToken(this.suite.options.balena.apiKey);
    this.log(`Logged in with ${await this.context.get().cloud.balena.auth.whoami()}'s account on ${this.suite.options.balena.apiUrl} using balenaSDK`);

    // create a balena application
    this.log("Creating application in cloud...");

    let appDeviceType = this.suite.deviceType.slug;
    // check to see if there is an existing release for this device type in balena cloud - if not, create a generic-arch fleet
    // This is required for new device types with no existing balena cloud releases, as the fleet creation fails if there are no releases yet
    // It can't accept invalid deviceType because we check contracts already in the start
    if (((await this.cloud.balena.models.os.getAvailableOsVersions(this.suite.deviceType.slug)).length) === 0) {
      appDeviceType = `generic-${this.suite.deviceType.data.arch}`;
      this.log(`No existing releases found for ${this.suite.deviceType.slug}... creating fleet with ${appDeviceType}`)
    }

    const app = await this.cloud.balena.models.application.create({
      name: this.balena.name,
      deviceType: appDeviceType,
      organization: this.balena.organization,
    });

    this.suite.context.set({
      balena: {
        name: app.app_name,
        application: app.slug,
      }
    });

    // remove application when tests are done
    this.suite.teardown.register(() => {
      this.log("Removing application");
      try {
        return this.cloud.balena.models.application.remove(
          this.balena.application
        );
      } catch(e){
        this.log(`Error while removing application...`)
      }
    });

    this.suite.context.set({
      appPath: `${__dirname}/test-app`,
      appServiceName: `containerA`
    })
    this.log(`Pushing release to app...`);
    const initialCommit = await this.cloud.pushReleaseToApp(this.balena.application, `${__dirname}/test-app`)
    this.suite.context.set({
      balena: {
        initialCommit: initialCommit
      }
    })

    // create an ssh key, so we can ssh into DUT later
    const keys = await this.utils.createSSHKey(this.sshKeyPath);
    await this.cloud.balena.models.key.create(
        this.balena.sshKey.label,
        keys.pubKey
      );
    this.suite.context.set({
      sshKey: keys
    })
    this.suite.teardown.register(() => {
      return Promise.resolve(
        this.cloud.removeSSHKey(this.balena.sshKey.label)
      );
    });

    // generate a uuid
    this.suite.context.set({
      balena: {
        uuid: this.cloud.balena.models.device.generateUniqueKey(),
      },
    });

    this.suite.context.set({
      os: new BalenaOS(
        {
          deviceType: this.suite.deviceType.slug,
          network: this.suite.options.balenaOS.network,
        },
        this.getLogger()
      ),
    });


    this.suite.context.set({
			workerContract: await this.worker.getContract()
		})

		// Unpack OS image .gz
		await this.os.fetch();
    await this.os.readOsRelease();

    // get config.json for application
    this.log("Getting application config.json...");
    const config = await this.cloud.balena.models.os.getConfig(this.balena.application, {
        version: this.os.contract.version,
      });

    config.uuid = this.balena.uuid;

    //register the device with the application, add the api key to the config.json
    this.log("Pre-registering a new device...");
    const deviceRegInfo = await this.cloud.balena.models.device.register(
        this.balena.application,
        this.balena.uuid
      );

    // Add registered device's id and api key to config.json
    config.deviceApiKey = deviceRegInfo.api_key;
    config.deviceId = deviceRegInfo.id;
    config.persistentLogging = true;
    config.developmentMode = true;
    config.installer = {
      secureboot: ['1', 'true'].includes(process.env.FLASHER_SECUREBOOT),
      migrate: { force: this.suite.options.balenaOS.config.installerForceMigration }
    };

    // Add config to suite context so accessible within tests. Main use case is to check secureboot status
    this.suite.context.set({
      config: config
    })

    if( this.workerContract.workerType === `qemu` && config.installer.migrate.force ) {
        console.log("Forcing installer migration")
    } else {
        console.log("No migration requested")
    }

    if ( config.installer.secureboot ) {
        console.log("Opting-in secure boot and full disk encryption")
    } else {
        console.log("No secure boot requested")
    }

    // get ready to populate DUT image config.json with the attributes we just generated
    this.os.addCloudConfig(config);

    // add DUT local hostname to context
    this.suite.context.set({
      link: `${this.balena.uuid.slice(0, 7)}.local`
    })

    // Teardown the worker when the tests end
    this.suite.teardown.register(() => {
      this.log("Worker teardown");
      return this.worker.teardown();
    });

    console.log('--config.json--')
    console.log(this.os.configJson);
    // preload image with the single container application
    this.log(`Device uuid should be ${this.balena.uuid}`)
    await this.os.configure();
    
    // Until secureboot flasher + preloading is implemented, skip preloading, and preloading test
    if ( config.installer.secureboot ) {
      console.log("Opting-in secure boot and full disk encryption - skip preloading")
    } else {
      console.log(`No secure boot requested, preloading image...`)
      await this.cli.preload(this.os.image.path, {
        app: this.balena.application,
        commit: initialCommit,
        pin: true,
      });
    }

    this.log("Setting up worker");
    await this.worker.network(this.suite.options.balenaOS.network);

    if (supportsBootConfig(this.suite.deviceType.slug)) {
      await enableSerialConsole(this.os.image.path);
    }

    if(flasherConfig(this.suite.deviceType.slug)){
			await setFlasher(this.os.image.path);
		}

    if(externalAnt(this.suite.deviceType.slug)){
			await enableExternalAntenna(this.os.image.path);
		}

    await this.worker.off();
    await this.worker.flash(this.os.image.path);

    // disable port forwarding on the testbot - disables the DUT internet access. We do this after flashing is completed
    // in case the flashing requires internet access - e.g jetson-flash container build
    if (
			this.workerContract.workerType !== `qemu`
		){
      await this.worker.executeCommandInWorker('sh -c "echo 0 > /proc/sys/net/ipv4/ip_forward"');
      this.suite.teardown.register(async () => {
        //re - enable port forwarding in case something flaked between us disabling it and re-enabling it
        console.log(`Ensuring worker port forwarding is active`)
        await this.worker.executeCommandInWorker('sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"');
      });
    }

    await this.worker.on();

    // create tunnels
		await test.resolves(
			this.worker.createSSHTunnels(
				this.link,
			),
			`Should detect ${this.link} on local network and establish tunnel`
		)

    this.log('Waiting for device to be reachable');
    await test.resolves(
			this.utils.waitUntil(async () => {
				let hostname = await this.worker.executeCommandInHostOS(
				"cat /etc/hostname",
				this.link
				)
				return (hostname === this.link.split('.')[0])
			}, true),
			`Device ${this.link} be reachable over local SSH connection`
		)

    await test.resolves(
			this.waitForServiceState('balena', 'active', this.link),
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
      await this.worker.archiveLogs(this.id, this.balena.uuid);
    });

  },
  tests: [
    "./tests/preload",
    "./tests/device-specific-tests/hostapd",
    "./tests/supervisor",
    "./tests/multicontainer",
    "./tests/ssh-auth",
    "./tests/os-config",
  ],
};
