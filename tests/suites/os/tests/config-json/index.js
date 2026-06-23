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

				return this.systemd.writeConfigJsonProp(test, 'hostname', hostname, context.link)
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
					return this.systemd.writeConfigJsonProp(test, 'hostname', null, context.link);
				});
			},
		},
		{
			title: 'ntpServers custom servers test',
			run: async function(test) {
				const context = this.context.get();
				const customServers = 'time.google.com time.cloudflare.com';

				await this.systemd.writeConfigJsonProp(test, 'ntpServers', customServers, context.link);

				// Wait for service to process
				await this.utils.waitUntil(async () => {
					const result = await context.worker.executeCommandInHostOS(
						'journalctl -u balena-ntp-config.service --no-pager | grep -q "Adding NTP sources" && echo found || echo missing',
						context.link,
					);
					return result.trim() === 'found';
				}, false, 60, 500);

				// Wait for chrony to show custom servers
				const customServerList = customServers.split(' ');
				await this.utils.waitUntil(async () => {
					const chronySources = await context.worker.executeCommandInHostOS(
						'chronyc sources',
						context.link,
					);

					// Check for time.google.com or time1.google.com, time2.google.com, etc.
					if (!/time\d*\.google\.com/.test(chronySources)) {
						test.comment('Chrony does not have time.google.com (or variant) in the sources');
						return false;
					}

					// Check for time.cloudflare.com or time1.cloudflare.com, time2.cloudflare.com, etc.
					if (!/time\d*\.cloudflare\.com/.test(chronySources)) {
						test.comment('Chrony does not have time.cloudflare.com (or variant) in the sources');
						return false;
					}

					return true;
				}, false, 60, 500);

				// Check added_config.sources exists
				const addedFileResult = await context.worker.executeCommandInHostOS(
					'test -f /run/chrony/added_config.sources && echo exists || echo missing',
					context.link,
				);
				test.is(addedFileResult.trim(), 'exists', 'added_config.sources file should exist');

				// Check default.sources does NOT exist
				const defaultFileResult = await context.worker.executeCommandInHostOS(
					'test -f /run/chrony/default.sources && echo exists || echo missing',
					context.link,
				);
				test.is(defaultFileResult.trim(), 'missing', 'default.sources should not exist');

				// Check added_config.sources contains custom servers with correct format
				const googleResult = await context.worker.executeCommandInHostOS(
					'grep -q "pool time.google.com iburst minpoll 14 maxpoll 14 maxsources 1" /run/chrony/added_config.sources && echo found || echo missing',
					context.link,
				);
				test.is(googleResult.trim(), 'found', 'added_config.sources should contain time.google.com');

				const cloudflareResult = await context.worker.executeCommandInHostOS(
					'grep -q "pool time.cloudflare.com iburst minpoll 14 maxpoll 14 maxsources 1" /run/chrony/added_config.sources && echo found || echo missing',
					context.link,
				);
				test.is(cloudflareResult.trim(), 'found', 'added_config.sources should contain time.cloudflare.com');

				// Cleanup: remove custom servers (triggers default behavior)
				await this.systemd.writeConfigJsonProp(test, 'ntpServers', null, context.link);
			},
		},
		{
			title: 'ntpServers default behavior test',
			run: async function(test) {
				const context = this.context.get();
				const defaultServers = [
					'0.resinio.pool.ntp.org',
					'1.resinio.pool.ntp.org',
					'2.resinio.pool.ntp.org',
					'3.resinio.pool.ntp.org',
				];

				// remove ntpServers from config.json (should trigger default behavior)
				await this.systemd.writeConfigJsonProp(test, 'ntpServers', null, context.link);

				// Wait for service to process
				await this.utils.waitUntil(async () => {
					const result = await context.worker.executeCommandInHostOS(
						'journalctl -u balena-ntp-config.service --no-pager | grep -q "Using default NTP sources" && echo found || echo missing',
						context.link,
					);
					return result.trim() === 'found';
				}, false, 60, 500);

				// Check default.sources file exists
				const defaultFileResult = await context.worker.executeCommandInHostOS(
					'test -f /run/chrony/default.sources && echo exists || echo missing',
					context.link,
				);
				test.is(defaultFileResult.trim(), 'exists', 'default.sources file should exist');

				// Check added_config.sources does NOT exist
				const addedFileResult = await context.worker.executeCommandInHostOS(
					'test -f /run/chrony/added_config.sources && echo exists || echo missing',
					context.link,
				);
				test.is(addedFileResult.trim(), 'missing', 'added_config.sources should not exist');

				// Check default.sources contains all 4 default pools
				for (const server of defaultServers) {
					const result = await context.worker.executeCommandInHostOS(
						`grep -q "${server}" /run/chrony/default.sources && echo found || echo missing`,
						context.link,
					);
					test.is(result.trim(), 'found', `default.sources should contain ${server}`);
				}
			},
		},
		{
			title: 'ntpServers null value test',
			run: async function(test) {
				const context = this.context.get();

				// set ntpServers to 'null'
				await this.systemd.writeConfigJsonProp(test, 'ntpServers', 'null', context.link);

				// Wait for service to process
				await this.utils.waitUntil(async () => {
					const result = await context.worker.executeCommandInHostOS(
						'journalctl -u balena-ntp-config.service --no-pager | grep -q "Default NTP sources disabled via config.json" && echo found || echo missing',
						context.link,
					);
					return result.trim() === 'found';
				}, false, 60, 500);

				// Check default.sources does NOT exist
				const defaultFileResult = await context.worker.executeCommandInHostOS(
					'test -f /run/chrony/default.sources && echo exists || echo missing',
					context.link,
				);
				test.is(defaultFileResult.trim(), 'missing', 'default.sources should not exist when ntpServers is "null"');

				// Check added_config.sources does NOT exist
				const addedFileResult = await context.worker.executeCommandInHostOS(
					'test -f /run/chrony/added_config.sources && echo exists || echo missing',
					context.link,
				);
				test.is(addedFileResult.trim(), 'missing', 'added_config.sources should not exist when ntpServers is "null"');

				// Cleanup: restore default behavior
				await this.systemd.writeConfigJsonProp(test, 'ntpServers', null, context.link);
			},
		},
		{
			title: 'dnsServers test',
			run: async function(test) {
				const defaultDns = '8.8.8.8';
				const exampleDns = '1.1.1.1';

				const context = this.context.get();

				return this.systemd.writeConfigJsonProp(test, 'dnsServers', `${exampleDns} ${exampleDns}`, context.link)
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
					return this.systemd.writeConfigJsonProp(test, 'dnsServers', 'null', context.link);
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
					return this.systemd.writeConfigJsonProp(test, 'dnsServers', null, context.link);
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

				return this.systemd.writeConfigJsonProp(test, 'os.network.connectivity', connectivity, context.link)
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
					return this.systemd.writeConfigJsonProp(test, 'os.network.connectivity', null, context.link);
				})
			},
		},
		{
			title: 'os.network.wifi.randomMacAddressScan test',
			run: async function(test) {
				const context = this.context.get();

				return this.systemd.writeConfigJsonProp(test, 'os.network.wifi.randomMacAddressScan', true, context.link)
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
					return this.systemd.writeConfigJsonProp(test, 'os.network.wifi.randomMacAddressScan', null, context.link);
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

				return this.systemd.writeConfigJsonProp(test, 'os.udevRules', rule, context.link)
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
					return this.systemd.writeConfigJsonProp(test, 'os.udevRules', null, context.link);
				});
			},
		},
		{
			title: 'persistentLogging configuration test',
			deviceType:{
				type: 'object',
				required: ['slug'],
				properties: {
				  slug: {
					not: {
					  const: "raspberry-pi"
					}
				  }
				}
			},
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
