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
	title: 'issue tests',
	tests: [
		{
			title: 'issue file check',
			run: async function(test) {
				const file = await this.context
					.get()
					.worker.executeCommandInHostOS(
						'cat /etc/issue',
						this.link,
					);

				const distroName = await this.context
					.get()
					.worker.executeCommandInHostOS(
						'cat /etc/os-release | grep "^NAME=" | cut -d "=" -f2 | tr -d \'"\'',
						this.link,
					);

				const osReleaseVersion = await this.context
					.get()
					.worker.getOSVersion(this.link)

				const result = {};
				file.split('\n').forEach(element => {
					const parse = /(\S*)\s(\S*)/.exec(element);
					result['distro'] = parse[1];
					result['version'] = parse[2];
				});

				// check distro
				test.is(
					result['distro'],
					`${distroName}`,
					`issue should contain distribution ${result['distro']}`,
				);
				// Check version
				test.is(
					result['version'],
					`${osReleaseVersion}`,
					`issue should contain version ${result['version']}`,
				);
			},
		},
		{
			title: 'issue.net file check',
			run: async function(test) {
				const file = await this.context
					.get()
					.worker.executeCommandInHostOS(
						'cat /etc/issue.net',
						this.link,
					);

				const distroName = await this.context
					.get()
					.worker.executeCommandInHostOS(
						'cat /etc/os-release | grep "^NAME=" | cut -d "=" -f2 | tr -d \'"\'',
						this.link,
					);

				const osReleaseVersion = await this.context
					.get()
					.worker.getOSVersion(this.link)

				const result = {};
				file.split('\n').forEach(element => {
					const parse = /(\S*)\s(\S*)/.exec(element);
					result['distro'] = parse[1];
					result['version'] = parse[2];
				});

				// check distro
				test.is(
					result['distro'],
					`${distroName}`,
					`issue.net should contain distribution ${result['distro']}`,
				);
				// Check version
				test.is(
					result['version'],
					`${osReleaseVersion}`,
					`issue.net should contain version ${result['version']}`,
				);
			},
		},
	],
};
