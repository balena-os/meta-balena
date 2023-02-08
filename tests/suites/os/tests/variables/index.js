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

module.exports = {
	title: 'Container exposed variables test',
	run: async function(test) {
		const ip = await this.worker.ip(this.link);

		await this.context
			.get()
			.worker.pushContainerToDUT(ip, __dirname, 'variables');
		const env = await this.context
			.get()
			.worker.executeCommandInContainer('env', 'variables', this.link);

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
				'APP_LOCK_PATH',
				'',
			].forEach(variable => {
				const fullVariable = `${prefix}${variable ? '_' + variable : ''}`;

				test.match(
					result,
					{
						[fullVariable]: /.*/,
					},
					`Should find ${fullVariable} in env`,
				);
			});
		});

		// This variable does not have a RESIN_ equivalent, so we will single it out
		test.match(
			result,
			{ BALENA_SERVICE_HANDOVER_COMPLETE_PATH: /.*/ },
			'Should find expected variable in env',
		);
	},
};
