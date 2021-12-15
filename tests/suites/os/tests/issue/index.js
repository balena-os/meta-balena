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
			title: 'issue file checks',
			tests: ['issue', 'issue.net'].map(adaptor => {
				return {
					title: `${adaptor} test`,
					run: async function(test) {
						let context = this.context.get();
						return context.worker.executeCommandInHostOS(
							`cat /etc/${adaptor}`,
							context.link,
						).then((file) => {
							const result = {};
							file.split('\n').forEach(element => {
								const parse = /(\S*)\s(\S*)/.exec(element);
								[ result['distro'], result['version'] ] = parse.slice(1);
							});

							return Promise.all(
								[
									context.worker.executeCommandInHostOS(
										'cat /etc/os-release | grep "^NAME=" | cut -d "=" -f2 | tr -d \'"\'',
										context.link,
									).then((distroName) => {
										test.is(
											result['distro'],
											distroName,
											`${adaptor} should contain distribution ${result['distro']}`);
									}),
									context.worker.getOSVersion(
										context.link,
									).then(osReleaseVersion => {
										test.is(
											result['version'],
											osReleaseVersion,
											`${adaptor} should contain version ${result['version']}`
										);
									}),
								],
							);
						});
					},
				}
			}),
		},
	],
};
