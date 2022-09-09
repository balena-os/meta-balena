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
const sshPath = join(homedir(), "id");

const setConfig = async (test, that, target, key, value) => {

	test.test(`Update or delete ${key} in config.json`, t =>
		t.resolves(
			that.waitForServiceState(
				'config-json.service',
				'inactive',
				target
			),
			'Should wait for config-json.service to be inactive'
		).then(() => {
			if (value == null) {
				return t.resolves(
					that.cloud.executeCommandInHostOS(
						[
							`tmp=$(mktemp)`,
							`&&`, `jq`, `"del(.${key})"`, `/mnt/boot/config.json`,
							`>`, `$tmp`, `&&`, `mv`, `"$tmp"`, `/mnt/boot/config.json`
						].join(' '),
						target
					), `Should delete ${key} from config.json`
				)
			} else {
				if (typeof(value) == 'string') {
					value = `"${value}"`
				} else {
					value = JSON.stringify(value);
				}

				return t.resolves(
					that.cloud.executeCommandInHostOS(
						[
							`tmp=$(mktemp)`,
							`&&`, `jq`, `'.${key}=${value}'`, `/mnt/boot/config.json`,
							`>`, `$tmp`, `&&`, `mv`, `"$tmp"`, `/mnt/boot/config.json`
						].join(' '),
						target
					), `Should set ${key} to ${value.substring(24) ? value.replace(value.substring(24), '...') : value} in config.json`
				)
			}
		}).then(() => {
			// avoid hitting 'start request repeated too quickly'
			return t.resolves(
				that.cloud.executeCommandInHostOS(
					'systemctl reset-failed config-json.service',
					target
				), `Should reset start counter of config-json.service`
			);
		}).then(() => {
			return t.resolves(
				that.waitForServiceState(
					'config-json.service',
					'inactive',
					target
				),
				'Should wait for config-json.service to be inactive'
			)
		})
	);
}

module.exports = {
	title: 'SSH authentication test',
	tests: [
		{
			title: 'SSH authentication in production mode',
			run: async function(test) {
				await fse.ensureDir(dirname(sshPath));
				const customKey = await keygen({
					location: sshPath,
				});
				return setConfig(test, this, this.balena.uuid, 'developmentMode', false)
				.then(() => {
					return setConfig(test, this, this.balena.uuid, 'os.sshKeys');
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
					return exec(`ssh-add ${sshPath}`)
					.then(() => {
						this.worker.addSSHKey(sshPath);
					})
					.then(() => {
						return setConfig(test, this, this.balena.uuid, 'os.sshKeys', [customKey.pubKey.trim()]);
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
						"Local SSH authentication with custom keys is allowed in production mode"
					);
			  }).then(async () => {
					await setConfig(test, this, this.balena.uuid, 'os.sshKeys');
			  }).then(async () => {
					let result;
					let ip = await this.worker.getDutIp(this.link);
					let config = {}
					await this.cloud.balena.models.key.create(this.suite.options.id, customKey.pubKey);
					config = {
						host: ip,
						port: '22222',
						username: this.worker.username,
						privateKeyPath: `${sshPath}`
					};
					await this.utils.waitUntil(
						async () => {
							try {
								result = await this.utils.executeCommandOverSSH('echo -n pass',
								config);
							} catch (err) {
								console.error(err.message);
								throw new Error(err);
							}
							return result
						}, false, 10, 5 * 1000);
					return test.equals(
						result.stdout,
						"pass",
						"Local SSH authentication with balenaCloud registered keys is allowed in production mode"
					)
					await this.cloud.balena.removeSSHKey(this.suite.options.id);
				});
			},
		},
		{
			title: 'SSH authentication in development mode',
			run: async function(test) {
				await fse.ensureDir(dirname(sshPath));
				const customKey = await keygen({
					location: sshPath,
				});
				return setConfig(test, this, this.balena.uuid, 'developmentMode', true)
				.then(() => {
					return setConfig(test, this, this.balena.uuid, 'os.sshKeys');
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
					return setConfig(test, this, this.balena.uuid, 'os.sshKeys', [customKey.pubKey.trim()]);
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
						return exec(`ssh-add ${sshPath}`)
						.then(() => {
							this.worker.addSSHKey(sshPath);
						})
						.then(() => {
							return setConfig(test, this, this.balena.uuid, 'os.sshKeys', [customKey.pubKey.trim()]);
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
					return setConfig(test, this, this.balena.uuid, 'os.sshKeys');
				}).then(async () => {
					let result;
					let ip = await this.worker.getDutIp(this.link);
					let config = {}
					await this.cloud.balena.models.key.create(this.suite.options.id, customKey.pubKey);
					config = {
						host: ip,
						port: '22222',
						username: this.worker.username,
						privateKeyPath: `${sshPath}`
					};
					await this.utils.waitUntil(
						async () => {
							try {
								result = await this.utils.executeCommandOverSSH('echo -n pass',
									config);
							} catch (err) {
								console.error(err.message);
								throw new Error(err);
							}
							return result
						}, false, 10, 5 * 1000);
					return test.equals(
						result.stdout,
						"pass",
						"Local SSH authentication with balenaCloud registered keys is allowed in development mode"
					)
					await this.cloud.balena.removeSSHKey(this.suite.options.id);
				});
			},
		},
	],
};
