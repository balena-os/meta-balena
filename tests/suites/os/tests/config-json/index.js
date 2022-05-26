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
	title: 'Config.json configuration tests',
	tests: [
		{
			title: 'hostname configuration test',
			run: async function(test) {
				const hostname = Math.random()
					.toString(36)
					.substring(2, 10);

				const context = this.context.get();

				test.comment(`Waiting for os-config-json service to be inactive...`);
				return context.systemd.waitForServiceState(
						'os-config-json.service',
						'inactive',
						context.link
				).then(() => {
					test.comment(`Setting hostname to ${hostname} in config.json...`);
					return context.worker.executeCommandInHostOS(
						[
							`tmp=$(mktemp)`,
							`&&`, `cat`,  `/mnt/boot/config.json`,
							`|`, `jq`, `'.hostname="${hostname}"'`,
							`>`, `$tmp`,
							`&&`, `mv`, `"$tmp"`, `/mnt/boot/config.json`,
						].join(' '),
						context.link);
				}).then(() => {
					return context.systemd.waitForServiceState(
						'avahi-daemon.service',
						'active',
						`${hostname}.local`,
					)
				}).then(() => {
					return context.worker.executeCommandInHostOS(
						'cat /etc/hostname',
						`${hostname}.local`
					)
				}).then((actual) => {
					const expected = hostname;
					test.equal(actual, expected, 'Device should have a new hostname');
				}).then(() => {
					// Remove hostname
					return context.worker.executeCommandInHostOS(
						[
							`tmp=$(mktemp)`,
							`&&`, `jq`, `"del(.hostname)"`, `/mnt/boot/config.json`,
							`>`, `$tmp`, `&&`, `mv`, `"$tmp"`, `/mnt/boot/config.json`
						].join(' '),
						`${hostname}.local`,
					);
				}).then(() => {
					// Wait for old hostname to be active again
					return context.systemd.waitForServiceState(
						'avahi-daemon.service',
						'active',
						context.link,
					);
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

				test.comment(`Waiting for os-config-json service to be inactive...`);
				return context.systemd.waitForServiceState(
						'os-config-json.service',
						'inactive',
						context.link
				).then(() => {
					test.comment(`Setting ntpServers to ${ntpServer()} in config.json...`);
					return context.worker.executeCommandInHostOS(
						[
							`tmp=$(mktemp)`,
							`&&`, `cat`, `/mnt/boot/config.json`,
							`|`, `jq`, `'.ntpServers="${ntpServer()}"'`, `>`, `$tmp`,
							`&&`, `mv`, `"$tmp"`, `/mnt/boot/config.json`,
						].join(' '),
						this.link);
				}).then(() => {
					test.comment(`Waiting for balena-ntp-config service to be active...`);
					return context.systemd.waitForServiceState(
						'balena-ntp-config.service',
						'active',
						context.link,
					)
				}).then(() => {
					return test.resolves(
						context.worker.executeCommandInHostOS(
							`chronyc sources | grep ${ntpServer('.*')}`,
							context.link,
						),
						'Device should show one record with our ntp server',
					);
				}).then(() => {
					return context.worker.executeCommandInHostOS(
						[
							`tmp=$(mktemp)`,
							`&&`, `cat`, `/mnt/boot/config.json`,
							`|`, `jq`, `"del(.ntpServers)"`, `>`, `$tmp`,
							`&&`, `mv`, `"$tmp"`, `/mnt/boot/config.json`,
						].join(' '),
						this.link,
					);
				});
			},
		},
		{
			title: 'dnsServers test',
			run: async function(test) {
				const defaultDns = '8.8.8.8';
				const exampleDns = '1.1.1.1';

				const context = this.context.get();

				test.comment(`Waiting for os-config-json service to be inactive...`);
				await context.systemd.waitForServiceState(
						'os-config-json.service',
						'inactive',
						context.link
				)
				test.comment(`Setting dnsServers to "${exampleDns} ${exampleDns}" in config.json...`);
				context.worker.executeCommandInHostOS(
					[
						`tmp=$(mktemp)`,
						`&&`, `jq`, `'.dnsServers="${exampleDns} ${exampleDns}"'`, `/mnt/boot/config.json`,
						`>`, `$tmp`, `&&`, `mv`, `"$tmp"`, `/mnt/boot/config.json`
					].join(' '),
					context.link
				);
				test.comment(`Waiting for dnsmasq to be active and using ${exampleDns}...`);
				await this.utils.waitUntil(async () => {
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
				}, false, 20, 500);
				test.comment(`Waiting for os-config-json service to be inactive...`);
				await context.systemd.waitForServiceState(
					'os-config-json.service',
					'inactive',
					context.link
				);
				test.comment(`Setting dnsServers to "null" in config.json...`);
				await context.worker.executeCommandInHostOS(
					[
						`tmp=$(mktemp)`,
						`&&`, `jq`, `'.dnsServers="null"'`, `/mnt/boot/config.json`, `>`, `$tmp`,
						`&&`, `mv`, `"$tmp"`, `/mnt/boot/config.json`
					].join(' '),
					context.link,
				);
				test.comment(`Waiting for dnsmasq service to be active...`);
				await context.systemd.waitForServiceState(
					'dnsmasq.service',
					'active',
					context.link
				);
				await Promise.all(
					[
						context.worker.executeCommandInHostOS(
							`cat /run/dnsmasq.servers`,
							context.link,
						).then((output) => {
							test.match(output,
								/^\s?$/,
								'We should have an empty /run/dnsmasq.servers file.');
						}),
						context.worker.executeCommandInHostOS(
							[
								'journalctl',
								'_SYSTEMD_INVOCATION_ID="$(systemctl show -p InvocationID --value dnsmasq.service)"',
								'|', 'grep', '-q', '"bad address"', ';', 'echo', '$?',
							].join(' '),
							context.link
						).then((output) => {
							test.is(output, '1', 'Active dnsmasq service should not log "bad address".');
						}),
					]
				);
				test.comment(`Waiting for os-config-json service to be inactive...`);
				await context.systemd.waitForServiceState(
					'os-config-json.service',
					'inactive',
					context.link
				);
				test.comment(`Removing dnsServers field from config.json...`);
				await context.worker.executeCommandInHostOS(
					[
						`tmp=$(mktemp)`,
						`&&`, `jq`, `"del(.dnsServers)"`, `/mnt/boot/config.json`, `>`, `$tmp`,
						`&&`, `mv`, `"$tmp"`, `/mnt/boot/config.json`
					].join(' '),
					context.link,
				);
				test.comment(`Waiting for dnsmasq to be active and using ${defaultDns}...`);
				await context.utils.waitUntil(async () => {
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
				}, false, 20, 500);
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

				test.comment('Configuring connectivity check in config.json')
				return context.worker.executeCommandInHostOS(
						[
							'tmp=$(mktemp)',
							'&&', 'jq', `'.os.network.connectivity=${JSON.stringify(connectivity)}'`,
								'/mnt/boot/config.json',
							'>', '$tmp', '&&', 'mv', '$tmp', '/mnt/boot/config.json',
						].join(' '),
						context.link,
				).then(() => {
					test.comment('Restarting os-networkmanager.service');
					return context.worker.executeCommandInHostOS(
						'systemctl restart os-networkmanager.service',
						context.link,
					);
				}).then(() => {
					return context.worker.executeCommandInHostOS(
						[
							'NetworkManager', '--print-config',
							'|', 'awk', '"/\\[connectivity\\]/{flag=1;next}/\\[/{flag=0}flag"',
						].join(' '),
						context.link,
					).then((config) => {
						test.is(
							/uri=(.*)\n/.exec(config)[1],
							connectivity.uri,
							`NetworkManager should be configured with uri: ${connectivity.uri}`,
						);
					});
				}).then(() => {
					return context.worker.executeCommandInHostOS(
						[
							'tmp=$(mktemp)',
							'&&', 'jq', '"del(.os.network.connectivity)"',
								'/mnt/boot/config.json',
							'>', '$tmp', '&&', 'mv', '$tmp', '/mnt/boot/config.json',
						].join(' '),
						context.link,
					);
				});
			},
		},
		{
			title: 'os.network.wifi.randomMacAddressScan test',
			run: async function(test) {
				const context = this.context.get();

				test.comment('Enabling randomMacAddressScan in config.json');
				return context.worker.executeCommandInHostOS(
					[
						'tmp=$(mktemp)',
						'&&', 'jq', "'.os.network.wifi.randomMacAddressScan=true'", '/mnt/boot/config.json',
						'>', '$tmp', '&&', 'mv', '$tmp', '/mnt/boot/config.json',
					].join(' '),
					context.link,
				).then(() => {
					test.comment('Restarting os-networkmanager.service');
					return context.worker.executeCommandInHostOS(
						'systemctl restart os-networkmanager.service',
						context.link,
					);
				}).then(() => {
					return context.worker.executeCommandInHostOS(
						[
							'NetworkManager', '--print-config',
							'|', 'awk', '"/\\[device\\]/{flag=1;next}/\\[/{flag=0}flag"',
						].join(' '),
						context.link,
					);
				}).then((config) => {
					test.match(
						config,
						/wifi.scan-rand-mac-address=yes/,
						'NetworkManager should be configured to randomize wifi MAC',
					);
				}).then(() => {
					return context.worker.executeCommandInHostOS(
						[
							'tmp=$(mktemp)',
							'&&', 'jq', "'del(.os.network.wifi)'", '/mnt/boot/config.json',
							'>', '$tmp', '&&', 'mv', '$tmp', '/mnt/boot/config.json',
						].join(' '),
						context.link,
					);
				});
			},
		},
		{
			title: 'udevRules test',
			run: async function(test) {
				const context = this.context.get();
				const rule = {
					99: 'ENV{ID_FS_LABEL_ENC}=="resin-boot", SYMLINK+="disk/test"',
				};

				test.comment('Adding udev rule to config.json');
				return context.worker.executeCommandInHostOS(
					[
						`tmp=$(mktemp)`,
						`&&`, `jq`, `'.os.udevRules=${JSON.stringify(rule)}'`, `/mnt/boot/config.json`,
						`>`, `$tmp`, `&&`, `mv`, `$tmp`, `/mnt/boot/config.json`,
					].join(' '),
					context.link,
				).then(() => {
					test.comment('Restarting os-udevrules.service');
					return context.worker.executeCommandInHostOS(
						'systemctl restart os-udevrules.service',
						context.link,
					);
				}).then(() => {
					test.comment('Reloading udev rules');
					return context.worker.executeCommandInHostOS(
						'udevadm trigger',
						context.link,
					);
				}).then(() => {
					return context.worker.executeCommandInHostOS(
						`readlink -e /dev/disk/test`,
						context.link,
					);
				}).then((linkTarget) => {
					return context.worker.executeCommandInHostOS(
						`readlink -e /dev/disk/by-label/resin-boot`,
						context.link,
					).then((deviceLink) => {
						test.is(linkTarget, deviceLink, 'Dev link should point to the correct device');
					});
				}).then(() => {
					return context.worker.executeCommandInHostOS(
						[
							'tmp=$(mktemp)',
							`&&`, `jq`, `'del(.os.udevRules)'`, `/mnt/boot/config.json`,
							`>`, '$tmp', `&&`, `mv`, '$tmp', `/mnt/boot/config.json`,
						].join(' '),
						context.link,
					);
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
