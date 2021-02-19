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

const retry = require('bluebird-retry');
const request = require('request-promise');

module.exports = {
	title: 'Container exposed variables test',
	os: {
		type: 'string',
		required: ['variant'],
		const: 'development',
	},
	run: async function(test) {
		const ip = await this.context.get().worker.ip(this.context.get().link);
		await retry(
			async () => {
				await this.context.get().balena.cli.push(ip, {
					source: __dirname,
				});
			},
			{
				max_tries: 60,
				interval: 5000,
			},
		);

		await retry(
			await this.context.get().utils.waitUntil(async () => {
				const state = await request({
					method: 'GET',
					uri: `http://${ip}:48484/v2/containerId`,
					json: true,
				});

				return state.services.variables != null;
			}),
			{
				max_tries: 60,
				interval: 5000,
			},
		);

		const state = await request({
			method: 'GET',
			uri: `http://${ip}:48484/v2/containerId`,
			json: true,
		});

		const env = await this.context
			.get()
			.worker.executeCommandInHostOS(
				`balena exec ${state.services.variables} env`,
				ip,
			);

		const result = {};
		env.split('\n').forEach(element => {
			const parse = /(.*)=(.*)/.exec(element);
			result[parse[1]] = parse[2];
		});

		['BALENA', 'RESIN'].forEach(prefix => {
			[
				'DEVICE_NAME_AT_INIT',
				'APP_ID',
				'APP_NAME',
				'SERVICE_NAME',
				'DEVICE_UUID',
				'DEVICE_TYPE',
				'HOST_OS_VERSION',
				'SUPERVISOR_VERSION',
				'APP_LOCK_PATH',
				'',
			].forEach(variable => {
				const fullVariable = `${prefix}${variable ? '_' + variable : ''}`;

				test.includes(
					result,
					{
						[fullVariable]: /.*/,
					},
					`Should find ${fullVariable} in env`,
				);
			});
		});

		// This variable does not have a BALENA_ equivalent, so we will single it out
		test.includes(
			result,
			{ BALENA_SERVICE_HANDOVER_COMPLETE_PATH: /.*/ },
			'Should find expected variable in env',
		);
	},
};
