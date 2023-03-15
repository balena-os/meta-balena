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

module.exports = {
  title: "Managed BalenaOS release suite",
  run: async function () {
    const Worker = this.require("common/worker");
    const BalenaOS = this.require("components/os/balenaos");
    const Balena = this.require("components/balena/sdk");
    // used for `preload`
    const CLI = this.require("components/balena/cli");
    const utils = this.require('common/utils');

    await fse.ensureDir(this.suite.options.tmpdir);

    // add objects to the context, so that they can be used across all the tests in this suite
    this.suite.context.set({
      cloud: new Balena(this.suite.options.balena.apiUrl, this.getLogger()),
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
        join(homedir(), 'id')),
      waitForServiceState: async function (serviceName, state, target) {
        return utils.waitUntil(
          async () => {
            return this.cloud
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
      }
    });

    // Network definitions - these are given to the testbot via the config sent via the config.js
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

    // Authenticating balenaSDK
    this.log("Logging into balena with balenaSDK");
    await this.cloud.balena.auth.loginWithToken(this.suite.options.balena.apiKey);

    // create a balena application
    this.log("Creating application in cloud...");
    const app = await this.cloud.balena.models.application.create({
      name: this.balena.name,
      deviceType: this.suite.deviceType.slug,
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
    await this.cli.preload(this.os.image.path, {
      app: this.balena.application,
      commit: initialCommit,
      pin: true,
    });

    this.log("Setting up worker");
    await this.worker.network(this.suite.options.balenaOS.network);

    if (supportsBootConfig(this.suite.deviceType.slug)) {
      await enableSerialConsole(this.os.image.path);
    }

    // disable port forwarding on the testbot - disables the DUT internet access.
    if (
			this.workerContract.workerType === `testbot`
		){
      await this.worker.executeCommandInWorker('sh -c "echo 0 > /proc/sys/net/ipv4/ip_forward"');
    }

    await this.worker.off();
    await this.worker.flash(this.os.image.path);
    await this.worker.on();

    // create tunnels
    this.log('Creating SSH tunnels to DUT');
    await this.worker.createSSHTunnels(
      this.link
    );

    this.log('Waiting for device to be reachable');
    await this.utils.waitUntil(async () => {
      this.log("Trying to ssh into device");
      let hostname = await this.context
        .get()
        .worker.executeCommandInHostOS(
          "cat /etc/hostname",
          this.link
        )
      return (hostname === `${this.balena.uuid.slice(0, 7)}`)
    }, true, 60, 5 * 1000);

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
