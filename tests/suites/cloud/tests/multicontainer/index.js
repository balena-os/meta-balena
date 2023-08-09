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
	title: 'Multicontainer app tests',

	tests: [
		{
			title: 'Set device environment variables',
			run: async function (test) {
				const key = 'deviceVar';
				const value = 'value';

				// set device variable
				await this.cloud.balena.models.device.envVar.set(
					this.balena.uuid,
					key,
					value,
				);

				// Check that device env variable is present in each service
				const services = [`containerA`, `containerB`];
				await this.utils.waitUntil(
					async () => {
						const results = {};
						for (const service of services) {
							const env = await this.cloud.executeCommandInContainer(
								`env`,
								service,
								this.balena.uuid,
							);
							if (env.includes(`${key}=${value}\n`)) {
								results[service] = true;
							} else {
								results[service] = false;
							}
						}
						return services.every((service) => {
							return results[service] === true;
						});
					},
					false,
					60,
					5 * 1000,
				);

				test.ok(true, `Should see device env variable`);
			},
		},
		{
			title: 'Set service environment variables',
			run: async function (test) {
				const key = 'serviceVar';
				const value = 'value';

				const services =
					await this.cloud.balena.models.device.getWithServiceDetails(
						this.balena.uuid,
					);

				// set device service variable for frontend service
				await this.cloud.balena.models.device.serviceVar.set(
					this.balena.uuid,
					services.current_services.containerA[0].service_id,
					key,
					value,
				);

				// Check to see if variable is present in front end service
				await this.utils.waitUntil(
					async () => {
						test.comment('Checking to see if variables are visible...');
						const env = await this.cloud.executeCommandInContainer(
							`env`,
							`containerA`,
							this.balena.uuid,
						);

						return env.includes(`${key}=${value}\n`);
					},
					false,
					60,
					5 * 1000,
				);
				test.ok(true, `Should service env var in service it was set for`);
			},
		},
	],
};
