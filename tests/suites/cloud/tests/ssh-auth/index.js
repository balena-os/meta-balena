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

const Bluebird = require('bluebird');
const keygen = Bluebird.promisify(require('ssh-keygen'));
const exec = Bluebird.promisify(require('child_process').exec);
const { join, dirname } = require("path");
const { homedir } = require("os");
const fse = require("fs-extra");

module.exports = {
	title: 'SSH authentication test',
	tests: [
		{
			title: 'SSH authentication in production mode',
			run: async function(test) {
        return this.writeConfigJsonProp(test, 'developmentMode', false, this.balena.uuid)
				.then(() => {
          return this.writeConfigJsonProp(test, 'os.sshKeys', null, this.balena.uuid)
				}).then(() => {
					return test.resolves(
						this.waitForServiceState(
							'os-sshkeys.service',
							'active',
							this.balena.uuid
						),
						'Should wait for os-sshkeys.service to be active'
					)
				}).then(async () => {
					return exec(`ssh-add ${this.context.get().sshKeyPath}`)
					.then(() => {
						this.worker.addSSHKey(this.context.get().sshKeyPath);
					})
				}).then(async () => {
					// disable retry, as we want to evaluate the failure
					const retryOptions = { max_tries: 0 };
					await this.worker.executeCommandInHostOS(
						'true',
						this.link,
						retryOptions,
					).then(() => {
						throw new Error("SSH authentication passed when it should have failed");
					}).catch((err) => {
						return test.match(
							err.message,
							/All configured authentication methods failed|Connection lost before handshake|Timed out while waiting for handshake/,
							"Local SSH authentication without custom keys is not allowed in production mode"
						);
					});
				}).then(async () => {
            return this.writeConfigJsonProp(test, 'os.sshKeys', [this.context.get().sshKey.pubKey.trim()], this.balena.uuid);
				}).then(async () => {
					let result;
					await this.utils.waitUntil(
						async () => {
							result = await this.worker.executeCommandInHostOS('echo -n pass',
								this.link);
							return result
						}, false, 10, 5 * 1000);
					return test.equals(
						result,
						"pass",
						"Local SSH authentication with custom keys is allowed in production mode"
					);
			  }).then(async () => {
          await this.writeConfigJsonProp(test, 'os.sshKeys', null, this.balena.uuid);
			  }).then(async () => {
					let result;
					let config = {};
					let ip = await this.worker.getDutIp(this.link);
					await this.utils.waitUntil(
						async () => {
							if (!this.worker.directConnect) {
									/* Because communication between core and DUT is a tunnel, this needs to be run directly on the worker */
									result = await this.worker.executeCommandInWorker(`sh -c "ssh -p 22222 -i /tmp/id -o StrictHostKeyChecking=no ${this.worker.username}@${ip} echo -n pass"`);
									return result
								} else {
									config = {
										host: ip,
										port: '22222',
										username: this.worker.username,
										privateKeyPath: this.context.get().sshKeyPath
									};
									result = await this.utils.executeCommandOverSSH(`echo -n pass`,
										config)
									result = result.stdout
									return result
								}
						}, false, 10, 5 * 1000);
					return test.equals(
						result,
						"pass",
						"Local SSH authentication with balenaCloud registered keys is allowed in production mode"
					)
				});
			},
		},
		{
			title: 'SSH authentication in development mode',
			run: async function(test) {
				const customSshPath = join(homedir(), 'custom_id')
				await fse.ensureDir(dirname(customSshPath));
				const customKey = await keygen({
					location: customSshPath,
				});
        return this.writeConfigJsonProp(test, 'developmentMode', true, this.balena.uuid)
				.then(() => {
          return this.writeConfigJsonProp(test, 'os.sshKeys', null, this.balena.uuid);
				}).then(() => {
					return test.resolves(
						this.waitForServiceState(
							'os-sshkeys.service',
							'active',
							this.balena.uuid
						),
						'Should wait for os-sshkeys.service to be active'
					)
				}).then( async () => {
					let result;
					await this.utils.waitUntil(
						async () => {
							result = await this.worker.executeCommandInHostOS('echo -n pass',
								this.link);
							return result
						}, false, 10, 5 * 1000);
					return test.equals(
						result,
						"pass",
						"Local SSH authentication without custom keys is allowed in development mode"
					)
				}).then(() => {
          return this.writeConfigJsonProp(test, 'os.sshKeys', [customKey.pubKey.trim()], this.balena.uuid);
				}).then(() => {
					return test.resolves(
						this.waitForServiceState(
							'os-sshkeys.service',
							'active',
							this.balena.uuid
						),
						'Should wait for os-sshkeys.service to be active'
					)
				}).then(async () => {
					return test.throws( function () {
						this.worker.executeCommandInHostOS(
							'echo -n pass',
							this.link)
						},
						{},
						"Local SSH authentication with phony custom keys is not allowed in development mode"
					)
				}).then(async () => {
						return exec(`ssh-add ${this.context.get().sshKeyPath}`)
						.then(() => {
							this.worker.addSSHKey(this.context.get().sshKeyPath);
						})
						.then(() => {
              return this.writeConfigJsonProp(test, 'os.sshKeys', [this.context.get().sshKey.pubKey.trim()], this.balena.uuid);
						});
				}).then(async () => {
					let result;
					await this.utils.waitUntil(
						async () => {
							result = await this.worker.executeCommandInHostOS('echo -n pass',
								this.link);
							return result
						}, false, 10, 5 * 1000);
					return test.equals(
						result,
						"pass",
						"Local SSH authentication with custom keys is allowed in development mode"
					)
				}).then(async () => {
          return this.writeConfigJsonProp(test, 'os.sshKeys', null, this.balena.uuid);
				}).then(async () => {
					let result;
					let config = {};
					let ip = await this.worker.getDutIp(this.link);
					await this.utils.waitUntil(
						async () => {
							if (!this.worker.directConnect) {
							/* Because communication between core and DUT is a tunnel, this needs to be run directly on the worker */
							result = await this.worker.executeCommandInWorker(`sh -c "ssh -p 22222 -i /tmp/id -o StrictHostKeyChecking=no ${this.worker.username}@${ip} echo -n pass"`);
							return result
						} else {
								config = {
									host: ip,
									port: '22222',
									username: this.worker.username,
									privateKeyPath: this.context.get().sshKeyPath
								};
								result = await this.utils.executeCommandOverSSH(`echo -n pass`,
									config)
								result = result.stdout
								return result
							}
						}, false, 10, 5 * 1000);
					return test.equals(
						result,
						"pass",
						"Local SSH authentication with balenaCloud registered keys is allowed in development mode"
					)
				});
			},
		},
	],
};
