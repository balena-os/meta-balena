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

const URL_TEST = 'ipv4.google.com';
const { join } = require('path');
const fs = require('fs');
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
						let connection = adaptor === 'wireless' ? 'balena-wifi' : 'Wired';
						return this.worker.executeCommandInHostOS(
							`nmcli d  | grep ' ${connection} ' | grep connected | awk '{print $1}'`,
							this.link,
						).then((iface) => {
							if (iface === '') {
								throw new Error(`No ${connection} connection found.`);
							}

							test.comment(`Attempting to connect to ${URL_TEST} over interface ${iface}`)
							return this.worker.executeCommandInHostOS(
								`curl -I -sS -o /dev/null -w "%{http_code}" --keepalive-time 5 --connect-timeout 5 --interface ${iface} ${URL_TEST}`,
								this.link,
							);
						}).then((curl) => {
							test.ok(
								curl.includes(200),
								`${URL_TEST} should respond over ${connection}`,
							);
						});
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
								['balena', 'ps', '-qf', 'name=proxy'],
								this.link
							);
						};
						let getRedsocksUid = async() => {
							return this.worker.executeCommandInHostOS(
								`id -u redsocks`,
								this.link
							);
						};

						return Promise.resolve(
							this.worker.ip(this.link)
						).then((ip) => {
							return getProxyContainerID().then((containerId) => {
								// Ensure we only push and run the proxy container once
								if (!containerId) {
									test.comment('Running proxy in container');
									return getRedsocksUid().then((redsocksUid) => {
										const composeFile = join(__dirname, './docker-compose.yml');
										try {
											let composeContents = fs.readFileSync(composeFile, 'utf8');
											let updatedCompose = composeContents.replace(/REDSOCKS_UID/g, redsocksUid.toString());
											fs.writeFileSync(composeFile, updatedCompose, 'utf8');
											test.comment("Updated docker-compose.yml with redsocks uid " + redsocksUid);
										} catch (err) {
											test.comment(`Failed to update docker-compose.yml - ` + err);
										}

										return this.worker.pushContainerToDUT(
											ip, __dirname, 'proxy'
										).then((state) => {
											test.comment(state);
										});
									});
								} else {
									test.comment('continer id exists');
								}
							});
						}).then(() => {
							return this.worker.executeCommandInHostOS(
								'mkdir -p /mnt/boot/system-proxy',
								this.link,
							);
						}).then(() => {
							test.comment(`Creating redsocks.conf for ${proxy}...`);
							return this.worker.executeCommandInHostOS(
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
						}).then(() => {
							// the supervisor would do this if proxy config were set via the supervisor sdk
							// https://www.balena.io/docs/reference/OS/network/2.x/#connecting-behind-a-proxy
							test.comment(`Manually restarting services...`);
							return this.worker.executeCommandInHostOS(
								'systemctl restart balena-proxy-config.service redsocks.service',
								this.link,
							);
						}).then(() => {
								return this.worker.executeCommandInHostOS(
									'systemctl is-active redsocks.service',
									this.link,
								)
						}).then((redsocksStatus) => {
							test.is(
								redsocksStatus,
								'active',
								'Redsocks proxy service should be active',
							);
						}).then(() => {
							return this.worker.executeCommandInHostOS(
								`curl -I https://${URL_TEST}`,
								this.link,
							);
						}).then(() => {
							return getProxyContainerID();
						}).then((containerId) => {
							test.comment('Getting proxy container logs...');
							return this.worker.executeCommandInHostOS(
								['balena', 'logs', containerId, '|', 'tail', '-n1'],
								this.link,
							);
						}).then((proxyLog) => {
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
						}).then(() => {
							test.comment(`Removing redsocks.conf...`);
							return this.worker.executeCommandInHostOS(
								'rm -rf /mnt/boot/system-proxy',
								this.link,
							);
						}).then(() => {
							test.comment(`Manually restarting services...`);
							return this.worker.executeCommandInHostOS(
								'systemctl restart balena-proxy-config.service redsocks.service',
								this.link,
							);
						});
					},
				};
			}),
		},
	],
};
