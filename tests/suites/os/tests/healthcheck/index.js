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

module.exports = {
	title: 'Container healthcheck test',
	run: async function(test) {
		const containerName = 'healthcheck';
		const context = this.context.get();

		async function retrieveHealthcheckEvents(deviceAddress, containerId) {
			return context.worker.executeCommandInHostOS(
				[
					`printf`, `'["null"';`, `balena`, `events`,
					`--filter`, `container=${containerId}`,
					`--filter`, `event=health_status`,
					`--since`, `1`,
					`--until`, `"$(date +%Y-%m-%dT%H:%M:%S.%NZ)"`,
					`--format`, `'{{json .}}'`,
					`|`, `while`, `read`, `LINE;`,
					`do`, `printf`, `",$LINE";`,
					`done;`, `printf`, `']'`,
				].join(' '),
				deviceAddress,
			).then((output) => {
				return Promise.resolve(JSON.parse(output));
			});
		}

		async function awaitHealthcheckHealthStatus(deviceAddress, containerId, targetStatus) {
			return context.utils.waitUntil(async () => {
				return retrieveHealthcheckEvents(deviceAddress, containerId).then((events) => {
					let status = events.reduce(
						function (result, element) {
							if (element.status != null) {
								result.push(element.status);
							}
							return result;
						},
						[],
					);

					return status.includes(`health_status: ${targetStatus}`);
				});
			}, false, 60, 1000);
		}

		let p = context.worker.ip(
			context.link
		).then((deviceAddress) => {
			test.comment(`Pushing container to DUT`);
			return context.worker.pushContainerToDUT(
				deviceAddress,
				__dirname,
				containerName,
			).then((state) => {
				let targetStatus = 'healthy';
				test.comment(`Waiting for container to report as ${targetStatus}...`);
				return awaitHealthcheckHealthStatus(
					deviceAddress,
					state.services.healthcheck,
					targetStatus,
				).then(() => {
					// cause the container healthcheck to fail
					return context.worker.executeCommandInContainer(
						'rm /tmp/health',
						containerName,
						deviceAddress,
					).then(() => {
						let targetStatus = 'unhealthy';
						test.comment(`Waiting for container to report as ${targetStatus}...`);
						return awaitHealthcheckHealthStatus(
							deviceAddress,
							state.services.healthcheck,
							targetStatus,
						);
					});
				});
			});
		});

		return test.resolves(p, 'Container should go from healthy to unhealthy');
	},
};
