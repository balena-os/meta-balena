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

module.exports = {
	title: 'OS-release tests',
	tests: [
		{
			title: 'OS-release file check',
			run: async function(test) {
				const file = await this.context
					.get()
					.worker.executeCommandInHostOS(
						'cat /etc/os-release',
						this.context.get().link,
					);

				const result = {};
				file.split('\n').forEach(element => {
					const parse = /(.*)=(.*)/.exec(element);
					result[parse[1]] = parse[2];
				});

				[
					'ID',
					'NAME',
					'VERSION',
					'VERSION_ID',
					'PRETTY_NAME',
					'MACHINE',
					'VARIANT',
					'VARIANT_ID',
					'META_BALENA_VERSION',
					//"RESIN_BOARD_REV",
					//"META_RESIN_REV",
					'SLUG',
				].forEach(field => {
					test.includes(
						result,
						{
							[field]: /.*/,
						},
						`OS-release file should contain field ${field}`,
					);
				});

				// check slug
				test.is(
					result['SLUG'],
					`"${this.context.get().os.deviceType}"`,
					`SLUG field should contain ${this.context.get().os.deviceType}`,
				);
			},
		},
	],
};
