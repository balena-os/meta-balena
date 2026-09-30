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

const net = require('net');
const fs = require('fs');
const { Client } = require('ssh2');

const ENGINE_TCP_PORT = 2375;
const SSH_PORT = 22222;
const ENGINE_SOCKET = '/var/run/balena-engine.sock';
const CONNECT_TIMEOUT_MS = 5000;
const PING_REQUEST = 'GET /_ping HTTP/1.0\r\n\r\n';
const PING_OK = '200 OK';

// Resolves the raw response to GET /_ping on host:port, or '' on failure.
// A TCP connect alone is not enough: leviathan may tunnel the port locally.
function pingEngineOverTcp(host, port) {
	return new Promise((resolve) => {
		let response = '';
		const socket = net.connect({ host, port, timeout: CONNECT_TIMEOUT_MS });
		socket.on('data', (data) => (response += data));
		socket.once('connect', () => socket.end(PING_REQUEST));
		socket.once('timeout', () => socket.destroy());
		socket.once('error', () => {});
		socket.once('close', () => resolve(response));
	});
}

// Resolves the raw response to GET /_ping through an SSH stream local forward
function pingEngineOverSSH(host, privateKeyPath) {
	return new Promise((resolve, reject) => {
		const conn = new Client();
		conn.once('error', reject);
		conn.once('ready', () => {
			conn.openssh_forwardOutStreamLocal(ENGINE_SOCKET, (err, stream) => {
				if (err) {
					conn.end();
					return reject(err);
				}
				let response = '';
				stream.on('data', (data) => (response += data));
				stream.once('close', () => {
					conn.end();
					resolve(response);
				});
				stream.end(PING_REQUEST);
			});
		});
		conn.connect({
			host,
			port: SSH_PORT,
			username: 'root',
			privateKey: fs.readFileSync(privateKeyPath),
			readyTimeout: CONNECT_TIMEOUT_MS,
		});
	});
}

async function setDevelopmentMode(test, enabled) {
	await this.systemd.writeConfigJsonProp(test, 'developmentMode', enabled, this.link);
	await this.utils.waitUntil(async () => {
		return (
			(await this.worker.executeCommandInHostOS(
				`systemctl is-active balena.service`,
				this.link,
			)) === 'active'
		);
	}, false);
}

async function assertEngineNotOnNetwork(test, mode) {
	const ip = await this.worker.ip(this.link);
	const response = await pingEngineOverTcp(ip, ENGINE_TCP_PORT);
	test.notOk(
		response.includes(PING_OK),
		`Engine should not answer on TCP port ${ENGINE_TCP_PORT} in ${mode} mode`,
	);
}

module.exports = {
	title: 'Engine socket exposure test',
	tests: [
		{
			title: 'Engine socket is only reachable through SSH in development mode',
			run: async function(test) {
				await setDevelopmentMode.call(this, test, true);
				await assertEngineNotOnNetwork.call(this, test, 'development');

				const ip = await this.worker.ip(this.link);
				const sshKeyPath = this.context.get().sshKeyPath;
				let response = '';
				await this.utils.waitUntil(async () => {
					response = await pingEngineOverSSH(ip, sshKeyPath);
					return response.includes(PING_OK);
				}, false, 5, 500);
				test.match(
					response,
					new RegExp(PING_OK),
					'Engine should answer through an SSH stream local forward',
				);
			},
		},
		{
			title: 'Engine socket is not exposed in production mode',
			run: async function(test) {
				await setDevelopmentMode.call(this, test, false);
				await assertEngineNotOnNetwork.call(this, test, 'production');
				test.comment(`Leaving system in development mode...`);
				await setDevelopmentMode.call(this, test, true);
			},
		},
	],
};
