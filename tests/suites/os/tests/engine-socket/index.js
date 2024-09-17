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
	title: 'Engine socket exposure test',
	tests: [
		{
			title: 'Engine socket is exposed in development images',
			run: async function(test) {
				const Docker = require('dockerode');
				let ip = await this.worker.ip(this.link)
				const docker = new Docker({host: `http://${ip}`, port: 2375})
				test.comment(`Setting system in development mode...`)
        await this.systemd.writeConfigJsonProp(test, 'developmentMode', true, this.link);
				test.comment(`Waiting for engine to restart...`)
				await this.utils.waitUntil(async () => {
					return (
						(await this.context
							.get()
							.worker.executeCommandInHostOS(
								`systemctl is-active balena.service`,
								this.link,
						)) == 'active'
					);
				}, false);
				test.comment(`Verify engine socket is exposed`)

				await test.resolves(
					this.utils.waitUntil(async () => {
						await new Promise((resolve, reject) => {
							docker.info(function (err, info) {
								if (err){
									reject(`Docker info failed: ${err}`);
								} else {
									console.log('got response, resolving!')
									resolve(info)
								}
							})
						})
						
						return true
					}, false, 5, 500),
					"Engine socket should be exposed in development images"
				);
			},
		},
		{
			title: 'Engine socket is not exposed in production images',
			run: async function(test) {
				const Docker = require('dockerode');
				let ip = await this.worker.ip(this.link)
				const docker = new Docker({host: `http://${ip}`, port: 2375})
				test.comment(`Setting system in production mode...`)
				await this.systemd.writeConfigJsonProp(test, 'developmentMode', false, this.link);
				test.comment(`Waiting for engine to restart...`)
				await this.utils.waitUntil(async () => {
					return (
						(await this.context
							.get()
							.worker.executeCommandInHostOS(
								`systemctl is-active balena.service`,
								this.link,
						)) == 'active'
					);
				}, false);
				test.comment(`Verify engine socket is not exposed`)

				await test.throws(
						docker.info(function (err, info) {
							if (!err && info && info.lenght) {
								throw new Error(`Docker info succeeded: ${info}`)
							}
						}), {},
					"Engine socket should not be exposed in production images"
				);
				test.comment(`Leaving system in development mode...`)
				await this.systemd.writeConfigJsonProp(test, 'developmentMode', true, this.link);
			},
		},
	],
};
