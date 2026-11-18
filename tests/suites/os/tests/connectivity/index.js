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
const request = require('request-promise');
const SUPERVISOR_PORT = 48484;
const { join } = require('path');
const fs = require('fs');
const { delay } = require('bluebird');

async function getProxyContainerID (context){
	return context.worker.executeCommandInHostOS(
		['balena', 'ps', '-qf', 'name=proxy'],
		context.link
	);
};

async function getRedsocksUid(context){
	return context.worker.executeCommandInHostOS(
		`id -u redsocks`,
		context.link
	);
};

async function setupProxyContainer(test, context, ip){
	return getProxyContainerID(context).then((containerId) => {
		// Ensure we only push and run the proxy container once
		if (!containerId) {
			test.comment('Running proxy in container');
			return getRedsocksUid(context).then((redsocksUid) => {
				const composeFile = join(__dirname, './docker-compose.yml');
				try {
					let composeContents = fs.readFileSync(composeFile, 'utf8');
					let updatedCompose = composeContents.replace(/REDSOCKS_UID/g, redsocksUid.toString());
					fs.writeFileSync(composeFile, updatedCompose, 'utf8');
					test.comment("Updated docker-compose.yml with redsocks uid " + redsocksUid);
				} catch (err) {
					test.comment(`Failed to update docker-compose.yml - ` + err);
				}

				return context.worker.pushContainerToDUT(
					ip, __dirname, 'proxy'
				).then((state) => {
					test.comment(state);
				});
			});
		} else {
			test.comment('continer id exists');
		}
	});
}

async function checkProxyFunctional(test, context, proxy){
	return context.worker.executeCommandInHostOS(
		`curl -I https://${URL_TEST}`,
		context.link,
	).then(() => {
		return getProxyContainerID(context);
	}).then((containerId) => {
		test.comment('Getting proxy container logs...');
		return context.worker.executeCommandInHostOS(
			['balena', 'logs', containerId, '|', 'tail', '-n1'],
			context.link,
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
	})
}

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
						return Promise.resolve(
							this.worker.ip(this.link)
						).then((ip) => {
							return setupProxyContainer(test, this, ip);
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
							return checkProxyFunctional(test, this, proxy);
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
		{
			// This tests that the supervisor host-config endpoint can successfully set a proxy configuration
			title: 'Supervisor configured proxy tests',
			tests: ['socks5', 'http-connect'].map(proxy => {
				return {
					title: `${proxy.charAt(0).toUpperCase()}${proxy.slice(1)} test`,
					run: async function(test) {
						return Promise.resolve(
							this.worker.ip(this.link)
						).then((ip) => {
							return setupProxyContainer(test, this, ip);
						}).then(() => {
							return this.worker.ip(this.link)
						}).then((ip) => {
							test.comment(`Creating redsocks.conf for ${proxy} via supervisor API...`);
							const supervisorProxyConf = {
								network: {
									proxy: {
										type: proxy,
										ip: '127.0.0.1',
										port: '8123',
										noProxy: [ "152.10.30.4", "253.1.1.0/16" ] // Include noProxy just to check that including it doesn't break the config
									},
								}
							}
							return request({
								method: 'PATCH',
								headers: {
									'Content-Type': 'application/json',
								},
								json: true,
								body: supervisorProxyConf,
								uri: `http://${ip}:${SUPERVISOR_PORT}/v1/device/host-config`,
							});
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
							return checkProxyFunctional(test, this, proxy);
						}).then(() => {
							return this.worker.ip(this.link)
						}).then((ip) => {
							test.comment(`Removing ${proxy} config via supervisor API...`);
							const supervisorProxyConf = {
								network: {
									proxy: {},
								}
							}
							return request({
								method: 'PATCH',
								headers: {
									'Content-Type': 'application/json',
								},
								json: true,
								body: supervisorProxyConf,
								uri: `http://${ip}:${SUPERVISOR_PORT}/v1/device/host-config`,
							});
						}).then(() => {
							// this delay is here as otherwise we may get an error from starting and stoping the proxy service too quickly in succession
							return delay(1000*10)
						})

					},
				};
			}),
		},
	],
};
