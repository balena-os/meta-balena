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
	title: 'Console access test',
	tests: [
		{
			title: 'Serial Console shell is available in development mode',
			run: async function(test) {
				/*
				const Bluebird = require('bluebird')
				const serialPortStream = Bluebird.promisify(require('@serialport/stream'))
				*/
				const serialStream = this.worker.serialStream();
				test.comment(`Setting system in development mode...`)
				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`tmp=$(mktemp)&&cat /mnt/boot/config.json | jq '.developmentMode="true"' > $tmp&&mv "$tmp" /mnt/boot/config.json`,
						this.link,
				);
				test.comment(`Waiting for engine to restart...`)
				await this.utils.waitUntil(async () => {
					return (
						(await this.context
							.get()
							.worker.executeCommandInHostOS(
								`systemctl is-active balena.service`,
								this.link,
						)) === 'active'
					);
				}, false);

				await serialStream.write(`pass`).then( () => {
					serialStream.on('data', (data) => {
						test.equal(
							data,
							"pass",
							"Serial console shell is available in development mode")
					})
				})
			},
		},
		{
			title: 'Serial console shell is not available in production mode',
			run: async function(test) {
				const serialStream = this.worker.serialStream();
				test.comment(`Setting system in production mode...`)
				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`tmp=$(mktemp)&&cat /mnt/boot/config.json | jq '.developmentMode="false"' > $tmp&&mv "$tmp" /mnt/boot/config.json`,
						this.link,
				);
				test.comment(`Waiting for engine to restart...`)
				await this.utils.waitUntil(async () => {
					return (
						(await this.context
							.get()
							.worker.executeCommandInHostOS(
								`systemctl is-active balena.service`,
								this.link,
						)) === 'active'
					);
				}, false);

				await test.throws( function () {
							serialStream.write(`pass`).then( () => {
								serialStream.on('data', (data) => {
									return data === 'pass'
								})
							})
						},
					{},
					"Serial console must not be available in production mode"
				);
				test.comment(`Leaving system in development mode...`)
				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`tmp=$(mktemp)&&cat /mnt/boot/config.json | jq '.developmentMode="true"' > $tmp&&mv "$tmp" /mnt/boot/config.json`,
						this.link,
				);
			},
		},
		/* TODO TTY console access */
	],
};
