/*
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

const request = require('request-promise');
const SUPERVISOR_PORT = 48484;
const fs = require('fs');

module.exports = {
	title: 'Device Tree tests',
	deviceType: {
		type: 'object',
		required: ['slug'],
		properties: {
			slug: {
				type: 'string',
				enum: [
					'raspberrypi3',
					'raspberrypi3-64',
					'raspberrypi4-64',
					'raspberry-pi2',
					'raspberry-pi',
				],
			},
		},
	},
	tests: [
		{
			title: 'DToverlay & DTparam tests',
			run: async function (test) {
				let ip = await this.worker.ip(this.link);
				let targetState

				// Export the GPIO pin
				const exportPin = async () => {
					return await this.worker.executeCommandInHostOS(
						`echo 4 >/sys/class/gpio/export`,
						this.link
					)
				}

				// Check value of GPIO pin and unexport the GPIO pin
				const getPinValue = async () => {
					const pinValue =  await this.worker.executeCommandInHostOS(
						`cat /sys/class/gpio/gpio4/value`,
						this.link
					)

					await this.worker.executeCommandInHostOS(
						`echo 4 >/sys/class/gpio/unexport`,
						this.link
					)
					return pinValue
				}

				// After applying Dtoverlay, the GPIO pins becomes unavailable as drivers take control over the pin
				// Hence, sysfs can't be used to query the value of the GPIO pin hence the user of /sys/kernel/debug/gpio
				const getPinValueThroughDebug = async () => {
					const getValue = fs.readFileSync(`${__dirname}/getValue.sh`).toString();
					return await this.worker.executeCommandInHostOS(
							`cd /tmp && ${getValue}`,
							this.link,
						);
				}

				const applySupervisorConfig = async (direction) => {
					// Wait for supervisor API to start
					await this.utils.waitUntil(async () => {
						return (
							(await request({
								method: 'GET',
								uri: `http://${ip}:${SUPERVISOR_PORT}/ping`,
							})) === 'OK'
						);
					}, false);

					targetState = {
						local: {
							name: 'local',
							config: {
								HOST_CONFIG_dtoverlay: `"gpio-key,gpio=4,active_low=0,gpio_pull=${direction}"`,
								HOST_CONFIG_dtparam:
									'"i2c_arm=on","spi=on","audio=on","foo=bar","level=42"',
								HOST_CONFIG_gpu_mem: '64',
								SUPERVISOR_PERSISTENT_LOGGING: 'true',
								SUPERVISOR_LOCAL_MODE: 'true',
							},
							apps: {},
						},
						dependent: {
							apps: [],
							devices: [],
						},
					};

					await this.context
						.get()
						.worker.executeCommandInHostOS(
							'touch /tmp/reboot-check',
							this.link,
						);

					// Setting the device tree variables using Supervisor API
					// This request reboots the DUT automatically
					const setTargetState = await request({
						method: 'POST',
						headers: {
							'Content-Type': 'application/json',
						},
						json: true,
						body: targetState,
						uri: `http://${ip}:${SUPERVISOR_PORT}/v2/local/target-state`,
					});

					test.same(
						setTargetState,
						{ status: 'success', message: 'OK' },
						'DToverlay & DTparam configured successfully',
					);

					await this.utils.waitUntil(async () => {
						test.comment('Waiting for DUT to come back online after reboot...');
						return (
							(await this.context
								.get()
								.worker.executeCommandInHostOS(
									'[[ ! -f /tmp/reboot-check ]] && echo "pass"',
									this.link,
								)) === 'pass'
						);
					}, false);

					// IP of the device sometimes change after reboots, hence initalising again
					// Commenting this to check if the IP really changes or not after reboot
					// If it does, then it's a bug, because the IP shouldn't change. 
					// If not, then remove the snippet
					// Leviathan issue: https://github.com/balena-os/leviathan/issues/781
					// ip = await this.worker.ip(this.link);

					await this.utils.waitUntil(async () => {
						test.comment('Waiting for supervisor to be ready after reboot...');
						return (
							(await request({
								method: 'GET',
								uri: `http://${ip}:${SUPERVISOR_PORT}/ping`,
							})) === 'OK'
						);
					}, false);

					return targetState
				}

				// Start of the device-tree practical test
				await exportPin(4)
				if (await getPinValue(4) === "0") {
					test.true(true, "Pin 4 was Low when the test started")
					const targetState = await applySupervisorConfig("up")
					test.equal(await getPinValueThroughDebug(4), '"hi"', "Pin 4 set to High after applying dtoverlay")
				} else {
					test.true(true, "Pin 4 is High as expected")
					const targetState = await applySupervisorConfig("down")
					test.equal(await getPinValueThroughDebug(4), '"lo"', "Pin 4 set to Low after applying dtoverlay")
				}

				// Get the current target state of device
				const currentState = await request({
					method: 'GET',
					uri: `http://${ip}:${SUPERVISOR_PORT}/v2/local/target-state`,
					json: true,
				});

				// Making sure currentState of the DUT matches the target state that was being set. 
				test.equal(
					currentState.state.local.config.HOST_CONFIG_dtoverlay,
					targetState.local.config.HOST_CONFIG_dtoverlay,
					'DToverlay successfully set in target state',
				);
				test.equal(
					currentState.state.local.config.HOST_CONFIG_dtparam,
					targetState.local.config.HOST_CONFIG_dtparam,
					'DTparam successfully set in target state',
				);

				const dtoverlay = fs.readFileSync(`${__dirname}/dtoverlay.sh`).toString();
				const dtparam = fs.readFileSync(`${__dirname}/dtparam.sh`).toString();

				const dtOverlayConfigTxt = await this.context
					.get()
					.worker.executeCommandInHostOS(
						`cd /tmp && ${dtoverlay}`,
						this.link,
					);

				test.equal(
					dtOverlayConfigTxt,
					targetState.local.config.HOST_CONFIG_dtoverlay,
					'DToverlays successfully configured in config.txt',
				);
				const dtParamConfigTxt = await this.context
					.get()
					.worker.executeCommandInHostOS(
						`cd /tmp && ${dtparam}`,
						this.link,
					);
				test.equal(
					dtParamConfigTxt,
					targetState.local.config.HOST_CONFIG_dtparam,
					'DTparams successfully configured in config.txt',
				);
				/* Static binary currently shared by RPI maintainer in gdrive only
				 * See: https://github.com/raspberrypi/Raspberry-Pi-OS-64bit/issues/67#issuecomment-653209729
				 */
				test.is(
					await this.context
						.get()
						.worker.executeCommandInHostOS(
							'cd /tmp/ && curl -L "https://drive.google.com/uc?export=download&id=1HS9E5vnxxNqrizB4mEYrnFoQQ1axSRKm" -o vcdbg && chmod +x ./vcdbg && \
							./vcdbg log msg 2>&1 | grep -q -i "File read:" ; echo $?',
							this.link,
						),
						'0',
						'vcdbg static binary should be downloaded and run successfuly'
				);
				test.is(
					await this.context
						.get()
						.worker.executeCommandInHostOS(
							'cd /tmp/ && ./vcdbg log msg 2>&1 | grep -q -i "Failed to load" ; echo $?',
							this.link,
						),
						'1',
						'vcdbg logs should be clean of device-tree or overlay load failures'
				);
			},
		},
	],
};
