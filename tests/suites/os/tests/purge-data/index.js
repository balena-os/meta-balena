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
	title: 'Reset tests',
	tests: [
		{
			title: 'state partition reset',
			run: async function(test) {
				const testFile = '/mnt/state/root-overlay/reset-check';
				const resetFile = '/mnt/state/remove_me_to_reset';

				test.comment(`Writing test file to state partition...`);
				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`touch ${testFile}`,
						this.link,
					);

				test.comment(`Clearing reset flag from state partition...`);
				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`rm ${resetFile}`,
						this.link,
					);

				// reboot
				await this.worker.rebootDut(this.link);

				test.comment(`Waiting for supervisor service to be active...`);
				await this.utils.waitUntil(async () => {
					return (
						(await this.context
							.get()
							.worker.executeCommandInHostOS(
								`systemctl is-active balena-supervisor.service`,
								this.link,
							)) === 'active'
					);
				}, false);

				test.is(
					await this.context
						.get()
						.worker.executeCommandInHostOS(
							`test -f ${testFile} ; echo $?`,
							this.link,
						),
					'1',
					`Test file should be cleared from state partition.`,
				);
			},
		},
		{
			title: 'data partition reset',
			run: async function(test) {
				const testFile = '/mnt/data/resin-data/reset-check';
				const resetFile = '/mnt/data/remove_me_to_reset';

				test.comment(`Waiting for engine service to be active...`);
				await this.utils.waitUntil(async () => {
					return (
						(await this.context
							.get()
							.worker.executeCommandInHostOS(
								`systemctl is-active balena.service`,
								this.link,
							)) === 'active'
					);
				}, false);

				test.comment(`Waiting for supervisor service to be active...`);
				await this.utils.waitUntil(async () => {
					return (
						(await this.context
							.get()
							.worker.executeCommandInHostOS(
								`systemctl is-active balena-supervisor.service`,
								this.link,
							)) === 'active'
					);
				}, false);

				test.is(
					await this.context
						.get()
						.worker.executeCommandInHostOS(
							`/usr/lib/balena/balena-healthcheck >/dev/null 2>&1 ; echo $?`,
							this.link,
						),
					'0',
					'Engine healthcheck should pass.',
				);

				test.comment(`Writing test file to data partition...`);
				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`touch ${testFile}`,
						this.link,
					);

				test.comment(`Clearing reset flag from data partition...`);
				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`rm ${resetFile}`,
						this.link,
					);

				// reboot
				await this.worker.rebootDut(this.link);

				test.comment(`Waiting for engine service to be active...`);
				await this.utils.waitUntil(async () => {
					return (
						(await this.context
							.get()
							.worker.executeCommandInHostOS(
								`systemctl is-active balena.service`,
								this.link,
							)) === 'active'
					);
				}, false);

				test.comment(`Waiting for supervisor service to be active...`);
				await this.utils.waitUntil(async () => {
					return (
						(await this.context
							.get()
							.worker.executeCommandInHostOS(
								`systemctl is-active balena-supervisor.service`,
								this.link,
							)) === 'active'
					);
				}, false);

				test.is(
					await this.context
						.get()
						.worker.executeCommandInHostOS(
							`/usr/lib/balena/balena-healthcheck >/dev/null 2>&1 ; echo $?`,
							this.link,
						),
					'0',
					'Engine healthcheck should pass.',
				);

				test.is(
					await this.context
						.get()
						.worker.executeCommandInHostOS(
							`test -f ${testFile} ; echo $?`,
							this.link,
						),
					'1',
					`Test file should be cleared from data partition.`,
				);
			},
		},
		{
			title: 'prune all images',
			run: async function(test) {
				test.comment(`Waiting for engine service to be active...`);
				await this.utils.waitUntil(async () => {
					return (
						(await this.context
							.get()
							.worker.executeCommandInHostOS(
								`systemctl is-active balena.service`,
								this.link,
							)) === 'active'
					);
				}, false);

				test.comment(`Waiting for supervisor service to be active...`);
				await this.utils.waitUntil(async () => {
					return (
						(await this.context
							.get()
							.worker.executeCommandInHostOS(
								`systemctl is-active balena-supervisor.service`,
								this.link,
							)) === 'active'
					);
				}, false);

				test.comment(`Pruning all container images...`);
				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`balena image prune --all --force`,
						this.link,
					);

				test.comment(`Waiting for supervisor service to be active...`);
				await this.utils.waitUntil(async () => {
					return (
						(await this.context
							.get()
							.worker.executeCommandInHostOS(
								`systemctl is-active balena-supervisor.service`,
								this.link,
							)) === 'active'
					);
				}, false);

				test.is(
					await this.context
						.get()
						.worker.executeCommandInHostOS(
							`/usr/lib/balena/balena-healthcheck >/dev/null 2>&1 ; echo $?`,
							this.link,
						),
					'0',
					'Engine healthcheck should pass.',
				);
			},
		},
	],
};
