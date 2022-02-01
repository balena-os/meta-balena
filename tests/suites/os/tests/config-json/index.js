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

				// Add hostname
				return this.worker.executeCommandInHostOS(
					[
						`tmp=$(mktemp)`,
						`&&`, `cat`,  `/mnt/boot/config.json`,
						`|`, `jq`, `'.hostname="${hostname}"'`,
						`>`, `$tmp`,
						`&&`, `mv`, `"$tmp"`, `/mnt/boot/config.json`,
					].join(' '),
					this.link,
				).then(() => {
					return this.systemd.waitForServiceState(
						'avahi-daemon.service',
						'active',
						`${hostname}.local`,
					)
				}).then(() => {
					return this.worker.executeCommandInHostOS(
						'cat /etc/hostname',
						`${hostname}.local`
					)
				}).then((actual) => {
					const expected = hostname;
					test.equal(actual, expected, 'Device should have a new hostname');
				}).then(() => {
					// Remove hostname
					return this.worker.executeCommandInHostOS(
						[
							`tmp=$(mktemp)`,
							`&&`, `jq`, `"del(.hostname)"`, `/mnt/boot/config.json`,
							`>`, `$tmp`, `&&`, `mv`, `"$tmp"`, `/mnt/boot/config.json`
						].join(' '),
						`${hostname}.local`,
					);
				}).then(() => {
					// Wait for old hostname to be active again
					return this.systemd.waitForServiceState(
						'avahi-daemon.service',
						'active',
						this.link,
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

				return this.worker.executeCommandInHostOS(
					[
						`tmp=$(mktemp)`,
						`&&`, `cat`, `/mnt/boot/config.json`,
						`|`, `jq`, `'.ntpServers="${ntpServer()}"'`, `>`, `$tmp`,
						`&&`, `mv`, `"$tmp"`, `/mnt/boot/config.json`,
					].join(' '),
					this.link,
				).then(() => {
					test.comment(`Waiting for balena-ntp-config service to be active...`);
					return this.systemd.waitForServiceState(
						'balena-ntp-config.service',
						'active',
						this.link,
					)
				}).then(() => {
					return test.resolves(
						this.worker.executeCommandInHostOS(
							`chronyc sources | grep ${ntpServer('.*')}`,
							this.link,
						),
						'Device should show one record with our ntp server',
					);
				}).then(() => {
					return this.worker.executeCommandInHostOS(
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

				test.comment(`Setting DNS nameservers to ${exampleDns} in config.json...`);
				return this.worker.executeCommandInHostOS(
					[
						`tmp=$(mktemp)`,
						`&&`, `jq`, `'.dnsServers="${exampleDns} ${exampleDns}"'`, `/mnt/boot/config.json`,
						`>`, `$tmp`, `&&`, `mv`, `"$tmp"`, `/mnt/boot/config.json`
					].join(' '),
					this.link,
				).then(() => {
					test.comment(`Waiting for dnsmasq to be active and using ${exampleDns}...`);
					return this.utils.waitUntil(async () => {
						return this.worker.executeCommandInHostOS(
							[
								`journalctl`,
								`_SYSTEMD_INVOCATION_ID="$(systemctl show -p InvocationID --value dnsmasq.service)"`,
								`|`, `grep`, `-q`, `${exampleDns}`, `;`, `echo`, `$?`
							].join(' '),
							this.link,
						).then((exitCode) => {
							return Promise.resolve(exitCode === '0');
						});
					}, false);
				}).then(() => {
					test.comment(`Setting dnsServers="null" in config.json...`);
					return this.worker.executeCommandInHostOS(
						[
							`tmp=$(mktemp)`,
							`&&`, `jq`, `'.dnsServers="null"'`, `/mnt/boot/config.json`, `>`, `$tmp`,
							`&&`, `mv`, `"$tmp"`, `/mnt/boot/config.json`
						].join(' '),
						this.link,
					);
				}).then(() => {
					test.comment(`Waiting for dnsmasq service to be active...`);
					return this.systemd.waitForServiceState(
						'dnsmasq.service',
						'active',
						this.link
					);
				}).then(() => {
					return Promise.all(
						[
							this.worker.executeCommandInHostOS(
								`grep -q '[^[:space:]]' < "/run/dnsmasq.servers" ; echo $?`,
								this.link,
							).then((output) => {
								test.is(output, '1', 'We should have an empty /run/dnsmasq.servers file.');
							}),
							this.worker.executeCommandInHostOS(
								[
									'journalctl',
									'_SYSTEMD_INVOCATION_ID="$(systemctl show -p InvocationID --value dnsmasq.service)"',
									'|', 'grep', '-q', '"bad address"', ';', 'echo', '$?',
								].join(' '),
								this.link
							).then((output) => {
								test.is(output, '1', 'Active dnsmasq service should not log "bad address".');
							}),
						]
					);
				}).then(() => {
					test.comment(`Removing dnsServers field from config.json...`);
					return this.worker.executeCommandInHostOS(
						[
							`tmp=$(mktemp)`,
							`&&`, `jq`, `"del(.dnsServers)"`, `/mnt/boot/config.json`, `>`, `$tmp`,
							`&&`, `mv`, `"$tmp"`, `/mnt/boot/config.json`
						].join(' '),
						this.link,
					);
				}).then(() => {
					test.comment(`Waiting for dnsmasq to be active and using ${defaultDns}...`);
					return this.utils.waitUntil(async () => {
						return this.worker.executeCommandInHostOS(
							[
								`journalctl`,
								`_SYSTEMD_INVOCATION_ID="$(systemctl show -p InvocationID --value dnsmasq.service)"`,
								`|`, `grep`, `-q`, defaultDns, `;`, `echo`, `$?`
							].join(' '),
							this.link,
						).then((exitCode) => {
							return Promise.resolve(exitCode === '0');
						});
					}, false);
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

				test.comment('Configuring connectivity check in config.json')
				return this.worker.executeCommandInHostOS(
						[
							'tmp=$(mktemp)',
							'&&', 'jq', `'.os.network.connectivity=${JSON.stringify(connectivity)}'`,
								'/mnt/boot/config.json',
							'>', '$tmp', '&&', 'mv', '$tmp', '/mnt/boot/config.json',
						].join(' '),
						this.link,
				).then(() => {
					test.comment('Restarting os-networkmanager.service');
					return this.worker.executeCommandInHostOS(
						'systemctl restart os-networkmanager.service',
						this.link,
					);
				}).then(() => {
					return this.worker.executeCommandInHostOS(
						[
							'NetworkManager', '--print-config',
							'|', 'awk', '"/\\[connectivity\\]/{flag=1;next}/\\[/{flag=0}flag"',
						].join(' '),
						this.link,
					).then((config) => {
						test.is(
							/uri=(.*)\n/.exec(config)[1],
							connectivity.uri,
							`NetworkManager should be configured with uri: ${connectivity.uri}`,
						);
					});
				}).then(() => {
					return this.worker.executeCommandInHostOS(
						[
							'tmp=$(mktemp)',
							'&&', 'jq', '"del(.os.network.connectivity)"',
								'/mnt/boot/config.json',
							'>', '$tmp', '&&', 'mv', '$tmp', '/mnt/boot/config.json',
						].join(' '),
						this.link,
					);
				});
			},
		},
		{
			title: 'os.network.wifi.randomMacAddressScan test',
			run: async function(test) {
				test.comment('Enabling randomMacAddressScan in config.json');
				return this.worker.executeCommandInHostOS(
					[
						'tmp=$(mktemp)',
						'&&', 'jq', "'.os.network.wifi.randomMacAddressScan=true'", '/mnt/boot/config.json',
						'>', '$tmp', '&&', 'mv', '$tmp', '/mnt/boot/config.json',
					].join(' '),
					this.link,
				).then(() => {
					test.comment('Restarting os-networkmanager.service');
					return this.worker.executeCommandInHostOS(
						'systemctl restart os-networkmanager.service',
						this.link,
					);
				}).then(() => {
					return this.worker.executeCommandInHostOS(
						[
							'NetworkManager', '--print-config',
							'|', 'awk', '"/\\[device\\]/{flag=1;next}/\\[/{flag=0}flag"',
						].join(' '),
						this.link,
					);
				}).then((config) => {
					test.match(
						config,
						/wifi.scan-rand-mac-address=yes/,
						'NetworkManager should be configured to randomize wifi MAC',
					);
				}).then(() => {
					return this.worker.executeCommandInHostOS(
						[
							'tmp=$(mktemp)',
							'&&', 'jq', "'del(.os.network.wifi)'", '/mnt/boot/config.json',
							'>', '$tmp', '&&', 'mv', '$tmp', '/mnt/boot/config.json',
						].join(' '),
						this.link,
					);
				});
			},
		},
		{
			title: 'udevRules test',
			run: async function(test) {
				const rule = {
					99: 'ENV{ID_FS_LABEL_ENC}=="resin-boot", SYMLINK+="disk/test"',
				};

				test.comment('Adding udev rule to config.json');
				return this.worker.executeCommandInHostOS(
					[
						`tmp=$(mktemp)`,
						`&&`, `jq`, `'.os.udevRules=${JSON.stringify(rule)}'`, `/mnt/boot/config.json`,
						`>`, `$tmp`, `&&`, `mv`, `$tmp`, `/mnt/boot/config.json`,
					].join(' '),
					this.link,
				).then(() => {
					test.comment('Restarting os-udevrules.service');
					return this.worker.executeCommandInHostOS(
						'systemctl restart os-udevrules.service',
						this.link,
					);
				}).then(() => {
					test.comment('Reloading udev rules');
					return this.worker.executeCommandInHostOS(
						'udevadm trigger',
						this.link,
					);
				}).then(() => {
					return this.worker.executeCommandInHostOS(
						`readlink -e /dev/disk/test`,
						this.link,
					);
				}).then((linkTarget) => {
					return this.worker.executeCommandInHostOS(
						`readlink -e /dev/disk/by-label/resin-boot`,
						this.link,
					).then((deviceLink) => {
						test.is(linkTarget, deviceLink, 'Dev link should point to the correct device');
					});
				}).then(() => {
					return this.worker.executeCommandInHostOS(
						[
							'tmp=$(mktemp)',
							`&&`, `jq`, `'del(.os.udevRules)'`, `/mnt/boot/config.json`,
							`>`, '$tmp', `&&`, `mv`, '$tmp', `/mnt/boot/config.json`,
						].join(' '),
						this.link,
					);
				});
			},
		},
		{
			title: 'sshKeys test',
			run: async function(test) {
				return test.resolves(
					this.worker.executeCommandInHostOS(
						'echo true',
						this.link,
					),
					'Should be able to establish ssh connection to the device',
				);
			},
		},
		{
			title: 'persistentLogging configuration test',
			run: async function(test) {
				async function getBootCount(that) {
					return that.worker.executeCommandInHostOS(
						'journalctl --list-boots | wc -l',
						that.link
					).then((output) => {
						return Promise.resolve(parseInt(output));
					});
				}

				return getBootCount(this).then((bootCount) => {
					return this.worker.rebootDut(this.link).then(() => {
						return getBootCount(this).then((testcount) => {
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
