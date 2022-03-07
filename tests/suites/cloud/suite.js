/*
 * Copyright 2018 balena
 *
 * @license Apache-2.0
 */

"use strict";

const Bluebird = require("bluebird");
const fse = require("fs-extra");
const { join } = require("path");
const { homedir } = require("os");
const util = require('util');
const exec = util.promisify(require('child_process').exec);

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
  title: "Managed BalenaOS release suite",
  run: async function () {
    const Worker = this.require("common/worker");
    const BalenaOS = this.require("components/os/balenaos");
    const Balena = this.require("components/balena/sdk");
    // used for `preload`
    const CLI = this.require("components/balena/cli");

    await fse.ensureDir(this.suite.options.tmpdir);

    // add objects to the context, so that they can be used across all the tests in this suite
    this.suite.context.set({
      cloud: new Balena(this.suite.options.balena.apiUrl, this.getLogger()),
      balena: {
        name: this.suite.options.id,
        organization: this.suite.options.balena.organization,
        sshKey: { label: this.suite.options.id },
        apiKey: this.suite.options.balena.apiKey,
      },
      cli: new CLI(this.suite.options.balena.apiUrl, this.getLogger()),
      sshKeyPath: join(homedir(), "id"),
      utils: this.require("common/utils"),
      worker: new Worker(this.suite.deviceType.slug, this.getLogger()),
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
    await this.context
      .get()
      .cloud.balena.auth.loginWithToken(this.suite.options.balena.apiKey);

    // create a balena application
    this.log("Creating application in cloud...");
    const app = await this.context.get().cloud.balena.models.application.create({
      name: this.context.get().balena.name,
      deviceType: this.suite.deviceType.slug,
      organization: this.context.get().balena.organization,
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
        return this.context
        .get()
        .cloud.balena.models.application.remove(
          this.context.get().balena.application
        );
      } catch(e){
        this.log(`Error while removing application...`)
      }
    });

    // Push a single container application
    this.log(`Cloning getting started repo...`);
    this.suite.context.set({
      appPath: `${__dirname}/app`
    })
    await exec(
      `git clone https://github.com/balena-io-examples/balena-node-hello-world.git ${this.context.get().appPath}`
    );
    this.log(`Pushing release to app...`);
    const initialCommit = await this.context.get().cloud.pushReleaseToApp(this.context.get().balena.application, `${__dirname}/app`)
    this.suite.context.set({
      balena: {
        initialCommit: initialCommit
      }
    })

    // create an ssh key, so we can ssh into DUT later
    await this.context
      .get()
      .cloud.balena.models.key.create(
        this.context.get().balena.sshKey.label,
        await this.context
          .get()
          .utils.createSSHKey(this.context.get().sshKeyPath)
      );
    this.suite.teardown.register(() => {
      return Bluebird.resolve(
        this.context
          .get()
          .cloud.removeSSHKey(this.context.get().balena.sshKey.label)
      );
    });

    // generate a uuid
    this.suite.context.set({
      balena: {
        uuid: this.context.get().cloud.balena.models.device.generateUniqueKey(),
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

    // unpack OS
    await this.context.get().os.fetch();

    // If this is a flasher image, and we are using qemu, unwrap
		if (
			this.suite.deviceType.data.storage.internal &&
			process.env.WORKER_TYPE === `qemu`
		) {
			const RAW_IMAGE_PATH = `/opt/balena-image-${this.suite.deviceType.slug}.balenaos-img`;
			const OUTPUT_IMG_PATH = '/data/downloads/unwrapped.img';
			console.log(`Unwrapping file ${this.context.get().os.image.path}`);
			console.log(`Looking for ${RAW_IMAGE_PATH}`);
			try {
				await imagefs.interact(
					this.context.get().os.image.path,
					2,
					async (fsImg) => {
						await pipeline(
							fsImg.createReadStream(RAW_IMAGE_PATH),
							fse.createWriteStream(OUTPUT_IMG_PATH),
						);
					},
				);

				this.context.get().os.image.path = OUTPUT_IMG_PATH;
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

    await this.context.get().os.readOsRelease();

    // get config.json for application
    this.log("Getting application config.json...");
    const config = await this.context
      .get()
      .cloud.balena.models.os.getConfig(this.context.get().balena.application, {
        version: this.context.get().os.contract.version,
      });

    config.uuid = this.context.get().balena.uuid;

    //register the device with the application, add the api key to the config.json
    this.log("Pre-registering a new device...");
    const deviceRegInfo = await this.context
      .get()
      .cloud.balena.models.device.register(
        this.context.get().balena.application,
        this.context.get().balena.uuid
      );
    
    // Add registered device's id and api key to config.json
    config.deviceApiKey = deviceRegInfo.api_key;
    config.deviceId = deviceRegInfo.id;
    config.persistentLogging = true;
    config.developmentMode= true;

    // get ready to populate DUT image config.json with the attributes we just generated
    this.context.get().os.addCloudConfig(config);

    // Teardown the worker when the tests end
    this.suite.teardown.register(() => {
      this.log("Worker teardown");
      return this.context.get().worker.teardown();
    });

    console.log('--config.json--')
    console.log(this.context.get().os.configJson);
    // preload image with the single container application
    this.log(`Device uuid should be ${this.context.get().balena.uuid}`)
    await this.context.get().os.configure();
    await this.context.get().cli.preload(this.context.get().os.image.path, {
      app: this.context.get().balena.application,
      commit: initialCommit,
      pin: true,
    });

    this.log("Setting up worker");
    await this.context
      .get()
      .worker.network(this.suite.options.balenaOS.network);

    if (supportsBootConfig(this.suite.deviceType.slug)) {
      await enableSerialConsole(this.context.get().os.image.path);
    }
    
    await this.context.get().worker.off();
    await this.context.get().worker.flash(this.context.get().os.image.path);
    await this.context.get().worker.on();

    this.suite.teardown.register(async () => {
      await this.context.get().worker.archiveLogs(this.id, `${this.context.get().balena.uuid.slice(0, 7)}.local`,);
    });

    this.log("Waiting for device to be reachable");
    await this.context.get().utils.waitUntil(async() => {
      console.log(`checking device is online in the dashboard....`)
      
      let isOnline =  await this.context
        .get()
        .cloud.balena.models.device.isOnline(this.context.get().balena.uuid);

      console.log(isOnline);
      return isOnline === true
    });

    this.log("Device is online and provisioned successfully");
    await this.context.get().utils.waitUntil(async () => {
      this.log("Trying to ssh into device");
      let hostname = await this.context
      .get()
      .cloud.executeCommandInHostOS(
        "cat /etc/hostname",
        this.context.get().balena.uuid
      )
      return hostname === this.context.get().balena.uuid.slice(0, 7)
    }, false);

    this.log("Unpinning");
    await this.context.get().utils.waitUntil(async () => {
      this.log(`Unpinning device from release`)
      await this.context
      .get()
      .cloud.balena.models.device.trackApplicationRelease(
        this.context.get().balena.uuid
      );

      let unpinned = await this.context
      .get()
      .cloud.balena.models.device.isTrackingApplicationRelease(this.context.get().balena.uuid)

      return unpinned
    }, false);

    // wait until the service is running before continuing
    await this.context.get().cloud.waitUntilServicesRunning(
      this.context.get().balena.uuid,
      [`main`],
      this.context.get().balena.initialCommit
    )
  },
  tests: [
    "./tests/preload",
    "./tests/supervisor",
    "./tests/multicontainer",
    "./tests/diagnostics"
  ],
};
