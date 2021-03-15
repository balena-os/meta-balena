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
	title: 'balena-engine healthcheck tests',
	tests: [
		{
			title: 'Healthcheck image exists',
			run: async function(test) {
				await this.context.get().utils.waitUntil(async () => {
					return (
						(await this.context
							.get()
							.worker.executeCommandInHostOS(
								`systemctl is-active --quiet balena.service && echo "pass"`,
								this.context.get().link,
							)) === 'pass'
					);
				});

				test.is(
					await this.context
						.get()
						.worker.executeCommandInHostOS(
							`/usr/lib/balena/balena-healthcheck >/dev/null 2>&1 && echo "pass"`,
							this.context.get().link,
						),
					"pass",
					"balena-healthcheck should pass."
				);
			},
		},
		{
			title: 'Healthcheck image pruned',
			run: async function(test) {
				await this.context.get().utils.waitUntil(async () => {
					return (
						(await this.context
							.get()
							.worker.executeCommandInHostOS(
								`systemctl is-active --quiet balena.service && echo "pass"`,
								this.context.get().link,
							)) === 'pass'
					);
				});
			
				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`balena image prune --all --force`,
						this.context.get().link,
					);

				test.is(
					await this.context
						.get()
						.worker.executeCommandInHostOS(
							`/usr/lib/balena/balena-healthcheck >/dev/null 2>&1 && echo "pass"`,
							this.context.get().link,
						),
					"pass",
					"balena-healthcheck should pass."
				);
			},
		},
	],
};
