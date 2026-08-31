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
		{
			title: 'Proxy redirect reconciliation tests',
			run: async function(test) {
				const host = async (cmd) =>
					this.worker.executeCommandInHostOS(cmd, this.link);
				const status = async () => host('balena-proxy-config status');
				const reconcile = async () =>
					host('systemctl start balena-proxy-watchdog.service');
				// The DNS redirect has to track the TCP one. Left behind while redsocks
				// is down it points UDP 53 at a closed port, which keeps the device off
				// the network however the TCP redirect is set.
				const DNS_RULE =
					'-p udp -m owner ! --uid-owner redsocks --dport 53 ' +
					'-j DNAT --to-destination 10.114.103.1:5313';
				const dnsRedirected = async () =>
					(
						await host(
							`iptables -w 10 -t nat -C OUTPUT ${DNS_RULE} && echo yes || echo no`,
						)
					).includes('yes');

				// The upstream proxy is deliberately absent. Every assertion below is
				// about the local listener and the iptables state, so an unreachable
				// proxy must not influence any of them.
				test.comment('Configuring a proxy with nothing listening upstream...');
				await host('mkdir -p /mnt/boot/system-proxy');
				await host(
					'printf "' +
						'base { \n' +
						'log_debug = off; \n' +
						'log_info = on; \n' +
						'log = stderr; \n' +
						'daemon = off; \n' +
						'redirector = iptables; \n' +
						'} \n' +
						'redsocks { \n' +
						'type = socks5; \n' +
						'ip = 127.0.0.1; \n' +
						'port = 8123; \n' +
						'local_ip = 127.0.0.1; \n' +
						'local_port = 12345; \n' +
						'} \n' +
						'dnsu2t { \n' +
						'local_ip = 127.0.0.1; \n' +
						'local_port = 5313; \n' +
						'remote_ip = 127.0.0.1; \n' +
						'remote_port = 53; \n' +
						'} \n" > /mnt/boot/system-proxy/redsocks.conf',
				);
				await host(
					'systemctl restart balena-proxy-config.service redsocks.service',
				);

				test.ok(
					(await status()).includes('redirect=engaged'),
					'Traffic should be redirected once redsocks is listening',
				);
				test.ok(
					await dnsRedirected(),
					'DNS should be redirected once redsocks is listening',
				);

				// The condition the reported outage happened under: the proxy itself is
				// unreachable. That is not a local fault and must not move the redirect.
				await reconcile();
				test.ok(
					(await status()).includes('redirect=engaged'),
					'Reconciling should leave the redirect alone when only the upstream proxy is unreachable',
				);

				test.comment('Stopping redsocks...');
				await host('systemctl stop redsocks.service');
				test.ok(
					(await status()).includes('redirect=disengaged'),
					'Stopping redsocks should disengage the redirect immediately',
				);
				test.is(
					await dnsRedirected(),
					false,
					'Stopping redsocks should take the DNS redirect out with the TCP one',
				);
				test.ok(
					(
						await host(
							`curl -I -sS -o /dev/null -w "%{http_code}" --connect-timeout 5 ${URL_TEST}`,
						)
					).includes('200'),
					`${URL_TEST} should resolve and respond directly while redsocks is down`,
				);

				test.comment('Forcing a redirect into a dead redsocks...');
				await host('iptables -w 10 -t nat -D REDSOCKS -p tcp -j RETURN');
				await host(`iptables -w 10 -t nat -A OUTPUT ${DNS_RULE}`);
				await reconcile();
				test.ok(
					(await status()).includes('redirect=disengaged'),
					'Reconciling should undo a redirect that points at a dead redsocks',
				);
				test.is(
					await dnsRedirected(),
					false,
					'Reconciling should undo a DNS redirect that points at a dead redsocks',
				);

				test.comment('Starting redsocks again...');
				await host('systemctl start redsocks.service');
				test.ok(
					(await status()).includes('redirect=engaged'),
					'Starting redsocks should engage the redirect again',
				);

				test.comment('Flushing the nat table under a healthy redsocks...');
				await host('iptables -w 10 -t nat -F');
				await reconcile();
				test.ok(
					(await status()).includes('redirect=engaged'),
					'Reconciling should rebuild the chain and the redirect after an external flush',
				);

				test.comment('Switching the failure action to reject...');
				await host('echo reject > /mnt/boot/system-proxy/on_proxy_failure');
				await host('systemctl stop redsocks.service');
				await reconcile();
				test.ok(
					(await status()).includes('redirect=engaged'),
					'The reject action should keep the redirect in place while redsocks is down',
				);
				await host('rm -f /mnt/boot/system-proxy/on_proxy_failure');

				test.is(
					await host('systemctl is-active balena-proxy-watchdog.timer'),
					'active',
					'The reconcile timer should be active',
				);

				// Nothing restarts balena-proxy-config here on purpose: reconciliation is
				// the only thing left to notice the configuration is gone.
				test.comment('Removing the proxy configuration...');
				await host('rm -rf /mnt/boot/system-proxy');
				await reconcile();
				const finalStatus = await status();
				test.ok(
					finalStatus.includes('config=absent') &&
						finalStatus.includes('redirect=absent') &&
						finalStatus.includes('jumps=no'),
					'Removing the configuration should leave no redirect behind',
				);
			},
		},
	],
};
