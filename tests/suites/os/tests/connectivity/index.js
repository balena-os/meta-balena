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

const URL_TEST = 'www.google.com';

module.exports = {
	title: 'Connectivity tests',
	tests: [
		{
			title: 'Interface tests',
			tests: ['wired', 'wireless'].map(adaptor => {
				return {
					title: `${adaptor.charAt(0).toUpperCase()}${adaptor.slice(1)} test`,
					os: {
						type: 'object',
						required: ['network'],
						properties: {
							network: {
								type: 'object',
								required: [adaptor],
								properties: {
									[adaptor]: {
										type: 'boolean',
										const: true,
									},
								},
							},
						},
					},
					run: async function(test) {
						let testIface = adaptor === 'wireless' ? 'wifi' : 'ethernet';
						const iface = await this.worker.executeCommandInHostOS(
							`nmcli d  | grep ' ${testIface} ' | grep connected | awk '{print $1}'`,
							this.link,
						);

						if (iface === '') {
							throw new Error(`No ${testIface} interface found.`);
						}

						let ping = await this.worker.executeCommandInHostOS(
							`ping -c 10 -i 0.002 -I ${iface} ${URL_TEST}`,
							this.link,
						);

						test.ok(
							ping.includes('10 packets transmitted, 10 packets received'),
							`${URL_TEST} responded over ${testIface}`,
						);
					},
				};
			}),
		},
		{
			title: 'Proxy tests',
			tests: ['socks5', 'http-connect'].map(proxy => {
				return {
					title: `${proxy.charAt(0).toUpperCase()}${proxy.slice(1)} test`,
					run: async function(test) {
						let getProxyContainerID = async() => {
							return this.worker.executeCommandInHostOS(
								['balena', 'ps', '-qf', 'name=proxy'].join(' '),
								this.link
							);
						};

						const ip = await this.worker.ip(this.link);

						// Ensure we only push and run the proxy container once
						if (!await getProxyContainerID()) {
							test.comment('Running proxy in container');
							const state = await this.worker.pushContainerToDUT(
								ip, __dirname, 'proxy'
							);
							test.comment(state);
						}

						await this.worker.executeCommandInHostOS(
							'mkdir -p /mnt/boot/system-proxy', this.link,
						);

						test.comment(`Creating redsocks.conf for ${proxy}...`);
						await this.worker.executeCommandInHostOS(
							'printf "' +
								'base { \n' +
								'log_debug = off; \n' +
								'log_info = on; \n' +
								'log = stderr; \n' +
								'daemon = off; \n' +
								'redirector = iptables; \n' +
								'} \n' +
								'redsocks { \n' +
								`type = ${proxy}; \n` +
								`ip = 127.0.0.1; \n` +
								`port = 8123; \n` +
								'local_ip = 127.0.0.1; \n' +
								'local_port = 12345; \n' +
								'} \n" > /mnt/boot/system-proxy/redsocks.conf',
							this.link,
						);

						// the supervisor would do this if proxy config were set via the supervisor sdk
						// https://www.balena.io/docs/reference/OS/network/2.x/#connecting-behind-a-proxy
						test.comment(`Manually restarting services...`);
						await this.worker.executeCommandInHostOS(
							'systemctl restart balena-proxy-config.service redsocks.service',
							this.link,
						);

						test.is(
							await this.worker.executeCommandInHostOS(
								'systemctl is-active redsocks.service',
								this.link,
							),
							'active',
							'Redsocks proxy service should be active',
						);

						await this.worker.executeCommandInHostOS(
							`curl -I https://${URL_TEST}`, this.link,
						);

						test.comment('Getting proxy container logs...');
						const proxyLog = await this.worker.executeCommandInHostOS(
							['balena',
								'logs',
								await getProxyContainerID(),
								'|', 'tail', '-n1'].join(' '),
							this.link,
						);

						const pattern = {
							'socks5': new RegExp(/\[socks5\] 127\.0\.0\.1:[0-9]* <->/),
							'http-connect': new RegExp(/\[http\] 127\.0\.0\.1:[0-9]* <->/),
						}[proxy];

						test.comment(`Looking for ${proxy} connection logs...`);
						test.match(
							proxyLog,
							pattern,
							`${URL_TEST} responded over ${proxy} proxy`
						);

						test.comment(`Removing redsocks.conf...`);
						await this.worker.executeCommandInHostOS(
							'rm -rf /mnt/boot/system-proxy', this.link,
						);

						test.comment(`Manually restarting services...`);
						await this.worker.executeCommandInHostOS(
							'systemctl restart balena-proxy-config.service redsocks.service',
							this.link,
						);
					},
				};
			}),
		},
	],
};
