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

module.exports = {
	title: 'Unmanaged BalenaOS release suite',
	run: async function() {
		const Worker = this.require('common/worker');
		const BalenaOS = this.require('components/os/balenaos');

		await fse.ensureDir(this.suite.options.tmpdir);

		this.suite.context.set({
			utils: this.require('common/utils'),
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
			os: new BalenaOS(
				{
					deviceType: this.suite.deviceType.slug,
					network: this.suite.options.balenaOS.network,
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
					},
				},
				this.getLogger(),
			),
		});

		this.suite.teardown.register(() => {
			this.log('Removing image');
			fse.unlinkSync('/data/image'); // Delete the unpacked an modified image from the testbot cache to prevent use in the next suite
			this.log('Worker teardown');
			return this.context.get().worker.teardown();
		});
		this.log('Setting up worker');
		await this.context
			.get()
			.worker.network(this.suite.options.balenaOS.network);

		await this.context.get().os.fetch({
			type: this.suite.options.balenaOS.download.type,
			version: this.suite.options.balenaOS.download.version,
			releaseInfo: this.suite.options.balenaOS.releaseInfo,
		});
		await this.context.get().os.configure();
		await this.context.get().worker.off(); // Ensure DUT is off before starting tests
		await this.context.get().worker.flash(this.context.get().os.image.path);
		await this.context.get().worker.on();

		this.log('Waiting for device to be reachable');
		assert.equal(
			await this.context
				.get()
				.worker.executeCommandInHostOS(
					'cat /etc/hostname',
					this.context.get().link,
				),
			this.context.get().link.split('.')[0],
			'Device should be reachable',
		);
	},
	tests: [
		'./tests/fingerprint',
		'./tests/led',
		'./tests/config-json',
		// The boot splash test is currently disabled because of the excessive time spent on it.
		// './tests/boot-splash',
		'./tests/connectivity',
		'./tests/engine-healthcheck',
	],
};
