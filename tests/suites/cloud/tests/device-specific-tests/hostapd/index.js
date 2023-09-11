/* Copyright 2019 balena
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

'use strict';
const util = require('util');
const exec = util.promisify(require('child_process').exec);

const waitUntilServicesRunning = async (that, uuid, services, commit, test) => {
	await that.utils.waitUntil(
		async () => {
			test.comment(
				`Waiting for device: ${uuid} to run services: ${services} at commit: ${commit}`,
			);
			let deviceServices = await that.cloud.balena.models.device.getWithServiceDetails(
				uuid,
			);
			let running = false;
			running = services.every(service => {
				return (
					deviceServices.current_services[service][0].status === 'Running' &&
					deviceServices.current_services[service][0].commit === commit
				);
			});
			return running;
		},
		false,
		60 * 10,
		1000,
	);
};

const waitUntilHotspotCreated = async (that, uuid, test) => {
	let result = false;
	await that.utils.waitUntil(
		async () => {
			test.comment(
				`Waiting for device: ${uuid} to create hotspot in container`,
			);
			let output = await that.cloud.executeCommandInHostOS(
				`if [[ -n "$(nmcli dev wifi list ifname wlan0 | grep -i test_eus)" ]]; then echo "PASSED"; else echo "FAILED"; fi`,
				uuid,
			);
			result = output === 'PASSED';

			return result;
		},
		true,
		10,
		5 * 1000,
	);
	return result;
};

module.exports = {
	deviceType: {
		type: 'object',
		required: ['slug'],
		properties: {
			slug: {
				type: 'string',
				const: '243390-rpi3',
			},
		},
	},
	title: 'Hostapd access-point test for EUS chipset',
	run: async function(test) {
		const hostapdAppName = `${this.balena.application}_Hostapd`;

		// create new application
		await this.cloud.balena.models.application.create({
			name: `${this.balena.name}_Hostapd`,
			deviceType: this.os.deviceType,
			organization: this.balena.organization,
		});

		this.context.set({
			moveApp: hostapdAppName,
		});

		this.suite.context.set({
			moveApp: hostapdAppName,
		});

		// Remove this app at the end of the test suite
		this.suite.teardown.register(() => {
			this.log(`Removing application ${hostapdAppName}`);
			try {
				return this.cloud.balena.models.application.remove(hostapdAppName);
			} catch (e) {
				this.log(`Error while removing application...`);
			}
		});

		// push hostapd app release to new app
		test.comment(`Cloning repo...`);
		await exec(
			`git clone https://github.com/balena-io-playground/hostapd_rtl8188eu.git ${__dirname}/app`,
		);

		test.comment(`Pushing release...`);
		const initialCommit = await this.cloud.pushReleaseToApp(
			hostapdAppName,
			`${__dirname}/app`,
		);
		this.suite.context.set({
			hostapd: {
				initialCommit: initialCommit,
			},
		});
		test.comment(`Release pushed succesfully...`);
	},
	tests: [
		{
			title: 'Move device to hostapd test App',
			run: async function(test) {
				await this.cloud.balena.models.device.move(
					this.balena.uuid,
					this.moveApp,
				);

				await waitUntilServicesRunning(
					this,
					this.balena.uuid,
					[`main`],
					this.hostapd.initialCommit,
					test,
				);

				let hotspotCreated = await waitUntilHotspotCreated(
					this,
					this.balena.uuid,
					test,
				);

				test.equal(
					hotspotCreated,
					true,
					'hostapd access point created successfuly',
				);
			},
		},
		{
			title: 'Move device back to original app',
			run: async function(test) {
				test.comment(
					`Will move device back to original app ${this.balena.application} `,
				);
				// move device back to original app
				await this.cloud.balena.models.device.move(
					this.balena.uuid,
					this.balena.application,
				);
				test.comment(
					`Moved device back to original app ${this.balena.application}, will now get commit`,
				);
				let commit = await this.cloud.balena.models.application.getTargetReleaseHash(
					this.balena.application,
				);
				await waitUntilServicesRunning(
					this,
					this.balena.uuid,
					[this.appServiceName],
					commit,
					test,
				);
				test.ok(
					true,
					`Device ${this.balena.application} is running its service`,
				);
			},
		},
	],
};
