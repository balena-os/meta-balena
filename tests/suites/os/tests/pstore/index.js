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

const PSTORE_ARCHIVE = '/var/lib/systemd/pstore';

module.exports = {
	title: 'pstore tests',
	tests: [
		{
			title: 'Kernel panic is reported on the next boot',
			run: async function(test) {
				const worker = this.context.get().worker;
				const link = this.link;
				// A non-zero exit makes the worker retry for minutes
				const exec = (cmd) => worker.executeCommandInHostOS(cmd, link);

				const node = await exec(
					'ls -d /proc/device-tree/reserved-memory/ramoops* 2>/dev/null || true',
				);
				if (node.trim() === '') {
					test.pass('No ramoops node in the device tree - skipping pstore test');
					return;
				}
				test.comment(`ramoops node: ${node.trim()}`);

				// Stage 1 arms ramoops only in OS_DEVELOPMENT images
				const armed = await exec(
					'grep -o "ramoops.mem_size=[^ ]*" /proc/cmdline || true',
				);
				if (armed.trim() === '') {
					test.pass(
						'Stage 1 passed no ramoops parameters (not an OS_DEVELOPMENT image?) - skipping pstore test',
					);
					return;
				}
				test.comment(`Stage 1 passed ${armed.trim()}`);

				const memSize = await exec(
					'cat /sys/module/ramoops/parameters/mem_size 2>/dev/null || echo 0',
				);
				test.not(
					Number(memSize.trim()),
					0,
					'ramoops should get a non-zero mem_size from the stage-1 kernel',
				);

				// The shutdown record check needs the previous boot on disk
				const persistent =
					(await exec(
						'systemctl is-active bind-var-log-journal.service || true',
					)).trim() === 'active';
				test.comment(`Persistent logging: ${persistent ? 'on' : 'off'}`);

				const marker = `leviathan-pstore-${Math.random().toString(36).slice(2)}`;
				await exec(`echo "${marker}" > /dev/kmsg`);

				test.comment('Triggering a kernel panic...');
				// With persistent logs, keeps this boot in "journalctl -b -1"
				await exec(
					`touch /tmp/reboot-check && journalctl --sync && sync && \
					systemd-run --on-active=2 /bin/sh -c 'echo c > /proc/sysrq-trigger'`,
				);
				await exec('[[ ! -f /tmp/reboot-check ]] && echo pass');
				test.comment('DUT is back online after the panic');

				await this.systemd.waitForServiceState(
					'balena-reset-reason.service',
					'active',
					link,
				);

				const report = await exec(
					'journalctl -b -t balena-reset-reason --no-pager -o cat || true',
				);
				test.match(
					report,
					/pstore dmesg-ramoops-\d+: \d+ bytes/,
					'balena-reset-reason should report the dmesg record',
				);
				test.match(
					report,
					new RegExp(`dmesg-ramoops-\\d+: .*${marker}`),
					'The dmesg record should hold the marker',
				);
				// Logged in full after an unclean or an unknown end
				test.match(
					report,
					/^console-ramoops-\d+: /m,
					'balena-reset-reason should log the console record',
				);
				if (persistent) {
					test.match(
						report,
						/previous boot ended without a shutdown record/,
						'balena-reset-reason should report an unclean end',
					);
				} else {
					test.notMatch(
						report,
						/previous boot ended/,
						'Without persistent logs the shutdown record check is silent',
					);
				}

				const leftover = await exec(
					`find ${PSTORE_ARCHIVE} -type f 2>/dev/null | wc -l`,
				);
				test.is(
					leftover.trim(),
					'0',
					`${PSTORE_ARCHIVE} should hold no record after the report`,
				);
			},
		},
	],
};
