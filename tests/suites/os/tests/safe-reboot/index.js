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

module.exports = {
	title: 'Safe reboot tests',
	tests: [
		{
			title: 'Respect application locks',
			run: async function(test) {
				let result = '';
				await this.worker.executeCommandInHostOS(
					`touch /tmp/reboot-check && \
					mkdir -p /tmp/balena-supervisor/services/test/ && \
					touch /tmp/balena-supervisor/services/test/updates.lock && \
					exec {FD}</tmp/balena-supervisor/services/test/updates.lock && \
					(flock -n $FD && sleep infinity) &`,
					this.link,
				)
				await this.worker.executeCommandInHostOS(
					'nohup /usr/libexec/safe_reboot > /dev/null 2>&1 &',
					this.link,
				)
				await this.utils.waitUntil(async () => {
					result = await this.worker.executeCommandInHostOS(
						'journalctl -n 20 | grep -q -e "/tmp/balena-supervisor/services/test/updates.lock exists"; echo $?',
						this.link,
					);
					return result === '0';
				},false, 20, 1000);
				test.is(
					result,
					'0',
					"Safe reboot waiting on application locks"
				);
				result = await this.worker.executeCommandInHostOS(
					'[[ -f /tmp/reboot-check ]] && echo "pass"',
					this.link,
				)
				test.is(
					result,
					'pass',
					'Should not reboot until application lock is removed'
				);
			},
		},
		{
			title: 'Reboot on application unlock',
			run: async function(test) {
				let result = '';

				await this.worker.executeCommandInHostOS(
					'killall sleep',
					this.link,
				)

				await this.utils.waitUntil(async () => {
					result = await this.worker.executeCommandInHostOS(
						'[[ ! -f /tmp/reboot-check ]] && echo "pass"',
						this.link,
					);
					return result === 'pass';
				}, false, 10, 1000);
				test.is(
					result,
					'pass',
					'Should reboot when application lock is removed'
				);
			},
		},
		{
			title: 'Override update locks',
			run: async function(test) {
				let ip = await this.worker.ip(this.link);

				// Wait for supervisor API to start
				await this.utils.waitUntil(async () => {
					return (
						(await request({
							method: 'GET',
							uri: `http://${ip}:${SUPERVISOR_PORT}/ping`,
						})) === 'OK'
					);
				}, false);

				let targetState
				let result = '';
				await this.worker.executeCommandInHostOS(
					`touch /tmp/reboot-check && \
					mkdir -p /tmp/balena-supervisor/services/test/ && \
					touch /tmp/balena-supervisor/services/test/updates.lock && \
					exec {FD}</tmp/balena-supervisor/services/test/updates.lock && \
					(flock -n $FD && sleep infinity) &`,
					this.link,
				)
				await this.worker.executeCommandInHostOS(
					'nohup /usr/libexec/safe_reboot > /dev/null 2>&1 &',
					this.link,
				)
				await this.utils.waitUntil(async () => {
					result = await this.worker.executeCommandInHostOS(
						'journalctl -n 20 | grep -q -e "/tmp/balena-supervisor/services/test/updates.lock exists"; echo $?',
						this.link,
					);
					return result === '0';
				},false, 20, 1000);
				test.is(
					result,
					'0',
					"Safe reboot waiting on application locks"
				);

				// Get the current state first - we need this as we must append it, rather than just blindly post a new
				// target state, to avoid overwriting any existing configuration
				let state = await request({
					method: 'GET',
					json: true,
					uri: `http://${ip}:${SUPERVISOR_PORT}/v2/local/target-state`,
				});

				state.state.local.config.SUPERVISOR_OVERRIDE_LOCK = "true"

				result = await this.worker.executeCommandInHostOS(
					'[[ -f /tmp/reboot-check ]] && echo "pass"',
					this.link,
				)
				test.is(
					result,
					'pass',
					'Should not reboot until override locks is present'
				);

				const setTargetState = await request({
					method: 'POST',
					headers: {
						'Content-Type': 'application/json',
					},
					json: true,
					body: state.state,
					uri: `http://${ip}:${SUPERVISOR_PORT}/v2/local/target-state`,
				});

				test.same(
					setTargetState,
					{ status: 'success', message: 'OK' },
					'Override locks configured successfully',
				);

				await this.utils.waitUntil(async () => {
					test.comment('Waiting for DUT to come back online after reboot...');
					result = await this.worker.executeCommandInHostOS(
						'[[ ! -f /tmp/reboot-check ]] && echo "pass"',
						this.link,
					)
					return result === 'pass';
				}, false, 10, 1000);

				test.is(
					result,
					'pass',
					'Should reboot when override lock is enabled');
			},
		},
	],
};
