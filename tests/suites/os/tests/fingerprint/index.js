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
	title: 'OS corruption tests',
	tests: [
		{
			title: 'resinos.fingerprint file test',
			run: async function(test) {
				let error = null;
				try {
					await this.context
						.get()
						.worker.executeCommandInHostOS(
							'md5sum --quiet -c /resinos.fingerprint',
							this.context.get().link,
						);
				} catch (e) {
					error = e;
				}

				test.is(error, null, 'Device rootfs seems to be corrupted');
			},
		},
	],
};
