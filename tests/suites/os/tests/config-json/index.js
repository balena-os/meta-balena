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

const setConfig = async (test, context, key, value) => {

	return context.systemd.waitForServiceState(
			'config-json.service',
			'inactive',
			context.link
	).then(() => {
		if (!value) {
			test.comment(`Removing ${key} from config.json...`);
			return context.worker.executeCommandInHostOS(
				[
					`tmp=$(mktemp)`,
					`&&`, `jq`, `"del(.${key})"`, `/mnt/boot/config.json`,
					`>`, `$tmp`, `&&`, `mv`, `"$tmp"`, `/mnt/boot/config.json`
				].join(' '),
				context.link);
		} else {
			if (typeof(value) == 'string') {
				value = `"${value}"`
			} else {
				value = JSON.stringify(value);
			}

			test.comment(`Setting ${key} to ${value} in config.json...`);
			return context.worker.executeCommandInHostOS(
				[
					`tmp=$(mktemp)`,
					`&&`, `jq`, `'.${key}=${value}'`, `/mnt/boot/config.json`,
					`>`, `$tmp`, `&&`, `mv`, `"$tmp"`, `/mnt/boot/config.json`
				].join(' '),
				context.link);
		}
	}).then(() => {
		// avoid hitting 'start request repeated too quickly'
		return context.worker.executeCommandInHostOS(
			'systemctl reset-failed config-json.service',
			context.link);
	}).then(() => {
		return context.systemd.waitForServiceState(
			'config-json.service',
			'inactive',
			context.link);
	});
}

module.exports = {
	title: 'Config.json configuration tests',
	tests: [
		{
			title: 'hostname configuration test',
			run: async function(test) {
				const hostname = Math.random()
					.toString(36)
					.substring(2, 10);

				const context = this.context.get();

				return setConfig(test, context, 'hostname', hostname) 
				.then(() => {
					return test.resolves(
						this.utils.waitUntil(async () => {
							return context.worker.executeCommandInHostOS(
								'cat /etc/hostname',
								`${hostname}.local`,
							).then((result) => {
								return Promise.resolve(hostname === result);
							});
						}, false, 20, 500),
						`${hostname}.local should resolve and /etc/hostname should contain ${hostname}`
					);
				}).then(() => {
					return setConfig(test, context, 'hostname');
				});
			},
		},
		{
			title: 'ntpServer test',
			run: async function(test) {
				const ntpServer = (regex = '') => {
					return `time${regex}.google.com`;
				};

				const context = this.context.get();

				return setConfig(test, context, 'ntpServers', ntpServer()) 
				.then(() => {
					return test.resolves(
						this.utils.waitUntil(async () => {
							return context.worker.executeCommandInHostOS(
								`chronyc sources | grep -q ${ntpServer('.*')} ; echo $?`,
								context.link,
							).then((exitCode) => {
								return Promise.resolve(exitCode === '0');
							});
						}, false, 60, 500),
						'Device should show one record with our ntp server'
					);
				}).then(() => {
					return setConfig(test, context, 'ntpServers');
				});
			},
		},
		{
			title: 'dnsServers test',
			run: async function(test) {
				const defaultDns = '8.8.8.8';
				const exampleDns = '1.1.1.1';

				const context = this.context.get();

				return setConfig(test, context, 'dnsServers', `${exampleDns} ${exampleDns}`)
				.then(() => {
					return test.resolves(
						this.utils.waitUntil(async () => {
							return context.worker.executeCommandInHostOS(
								[
									`journalctl`,
									`_SYSTEMD_INVOCATION_ID="$(systemctl show -p InvocationID --value dnsmasq.service)"`,
									`|`, `grep`, `-q`, `${exampleDns}`, `;`, `echo`, `$?`
								].join(' '),
								context.link,
							).then((exitCode) => {
								return Promise.resolve(exitCode === '0');
							});
						}, false, 20, 500),
						`Active dnsmasq service should include ${exampleDns} in the logs`
					)
				}).then(() => {
					return setConfig(test, context, 'dnsServers', 'null');
				}).then(() => {
					return test.resolves(
						this.utils.waitUntil(async () => {
							return context.worker.executeCommandInHostOS(
								'cat /run/dnsmasq.servers',
								context.link,
							).then((servers) => {
								return Promise.resolve(!servers.replace(/\s/g, '').length);
							})
						}, false, 20, 500),
						'/run/dnsmasq.servers should be empty'
					);
				}).then(() => {
					return context.worker.executeCommandInHostOS(
						[
							'journalctl',
							'_SYSTEMD_INVOCATION_ID="$(systemctl show -p InvocationID --value dnsmasq.service)"',
							'|', 'grep', '-q', '"bad address"', ';', 'echo', '$?',
						].join(' '),
						context.link
					).then((output) => {
						return test.is(output, '1', 'Active dnsmasq service should not log "bad address".');
					});
				}).then(() => {
					return setConfig(test, context, 'dnsServers');
				}).then(() => {
					return test.resolves(
						context.utils.waitUntil(async () => {
							return context.worker.executeCommandInHostOS(
								[
									`journalctl`,
									`_SYSTEMD_INVOCATION_ID="$(systemctl show -p InvocationID --value dnsmasq.service)"`,
									`|`, `grep`, `-q`, defaultDns, `;`, `echo`, `$?`
								].join(' '),
								context.link,
							).then((exitCode) => {
								return Promise.resolve(exitCode === '0');
							});
						}, false, 20, 500),
						`Active dnsmasq service should include ${defaultDns} in the logs`
					);
				});
			},
		},
		{
			title: 'os.network.connectivity test',
			os: {
				type: 'object',
				required: ['version'],
				properties: {
					version: {
						type: 'string',
						semver: {
							gt: '2.34.0',
						},
					},
				},
			},
			run: async function(test) {
				const connectivity = {
					uri: 'http://www.archlinux.org/check_network_status.txt',
				};

				const context = this.context.get();

				return setConfig(test, context, 'os.network.connectivity', connectivity)
				.then(() => {
					return test.resolves(
						this.utils.waitUntil(async () => {
							return context.worker.executeCommandInHostOS(
								[
									'NetworkManager', '--print-config',
									'|', 'awk', '"/\\[connectivity\\]/{flag=1;next}/\\[/{flag=0}flag"',
								].join(' '),
								context.link,
							).then((config) => {
								return Promise.resolve(
									/uri=(.*)\n/.exec(config)[1] === connectivity.uri
								);
							});
						}, false, 60, 500),
						`NetworkManager should be configured with uri ${connectivity.uri}`
					);
				}).then(() => {
					return setConfig(test, context, 'os.network.connectivity');
				})
			},
		},
		{
			title: 'os.network.wifi.randomMacAddressScan test',
			run: async function(test) {
				const context = this.context.get();

				return setConfig(test, context, 'os.network.wifi.randomMacAddressScan', true)
				.then(() => {
					return test.resolves(
						this.utils.waitUntil(async () => {
							return context.worker.executeCommandInHostOS(
								[
									'NetworkManager', '--print-config',
									'|', 'awk', '"/\\[device\\]/{flag=1;next}/\\[/{flag=0}flag"',
								].join(' '),
								context.link,
							).then((config) => {
								return Promise.resolve(
									/wifi.scan-rand-mac-address=yes/.test(config)
								);
							});
						}, false, 60, 500),
						'NetworkManager should be configured to randomize wifi MAC'
					);
				}).then(() => {
					setConfig(test, context, 'os.network.wifi.randomMacAddressScan');
				});
			},
		},
		{
			title: 'udevRules test',
			run: async function(test) {
				const context = this.context.get();
				const linkPath = 'disk/test';
				const rule = {
					99: `ENV{ID_FS_LABEL_ENC}=="resin-boot", SYMLINK+="${linkPath}"`,
				};

				return setConfig(test, context, 'os.udevRules', rule)
				.then(() => {
					test.comment('Reloading udev rules...');
					return context.worker.executeCommandInHostOS(
						'udevadm trigger',
						context.link,
					);
				}).then(() => {
					// This readlink command can fail if the link hasn't been created by
					// the relevant udev rule yet, so test that it exists beforehand
					return this.utils.waitUntil(
						() => context.worker.executeCommandInHostOS(
							`test -L /dev/${linkPath}`,
							context.link,
						).then(() => true),
						false, 30 * 4, 250
					).then(
						() => context.worker.executeCommandInHostOS(
							`readlink -e /dev/${linkPath}`,
							context.link,
						)
					);
				}).then((linkTarget) => {
					return context.worker.executeCommandInHostOS(
						`readlink -e /dev/disk/by-label/resin-boot`,
						context.link,
					).then((deviceLink) => {
						test.is(linkTarget, deviceLink, 'Dev link should point to the correct device');
					});
				}).then(() => {
					return setConfig(test, context, 'os.udevRules');
				});
			},
		},
		{
			title: 'persistentLogging configuration test',
			run: async function(test) {
				const context = this.context.get();

				async function getBootCount() {
					return context.worker.executeCommandInHostOS(
						'journalctl --list-boots | wc -l',
						context.link
					).then((output) => {
						return Promise.resolve(parseInt(output));
					});
				}

				return getBootCount().then((bootCount) => {
					return context.worker.rebootDut(context.link).then(() => {
						return getBootCount().then((testcount) => {
							test.is(
								testcount === bootCount + 1,
								true,
								`Device should show previous boot records, showed ${testcount} boots`,
							);
						});
					});
				});
			},
		},
	],
};
