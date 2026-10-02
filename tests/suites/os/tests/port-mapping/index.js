/* Copyright 2019 balena
 *
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
const request = require('request-promise');

module.exports = {
	title: 'Container port mapping test',
	run: async function(test) {
		const ip = await this.worker.ip(this.link);
		const TEST_WORD = "test";
		// these values should match those in the docker-compose.yml
		const CONTAINER_PORT = "1337";
		const HOST_PORT = "1337";

		// if this is a physical DUT, we must create a tunnel the DUT port
		if(this.workerContract.workerType !== `qemu`){
			console.log(`Creating tunnel to DUT port ${HOST_PORT}...`)
			await this.worker.createTunneltoDUT(this.link, HOST_PORT, HOST_PORT);
		}

		await this.worker.pushContainerToDUT(ip, __dirname, 'port-map');
		await this.worker.executeCommandInContainer(`sh -c '{ echo -ne "HTTP/1.0 200 OK\r\n\r\n"; echo "${TEST_WORD}"; } | nc -l -p ${CONTAINER_PORT} &'`, 'port-map', this.link);


		console.log("Attmpting get...");
		// check port of DUT for test word
		let result = await request({
			method: 'GET',
			uri: `http://${ip}:${HOST_PORT}/`,
		})
		test.is(result.trim(), TEST_WORD, `Should see content on exposed port`);	
	},
};
