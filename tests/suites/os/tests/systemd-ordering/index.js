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

/*
 * Regression guard for systemd ordering cycles in the boot transaction.
 *
 * A cycle linked the fake-hwclock / resin-state chain to the early filesystem
 * units:
 *
 *   resin-state-reset.service -> var-volatile.mount -> local-fs-pre.target
 *     -> systemd-remount-fs.service -> systemd-fsck-root.service
 *     -> fake-hwclock.service -> etc-fake-hwclock.mount -> resin-state-reset.service
 *
 * plus a second loop closed only by the implicit After=local-fs-pre.target that
 * etc-fake-hwclock.mount inherited as a local mount. systemd breaks a cycle by
 * deleting one job, and the victim is randomly seeded per boot. On unlucky
 * boots var-volatile.mount was deleted: no /var/volatile tmpfs, dangling
 * /var/log, crash-looping supervisor, device offline until the next reboot.
 *
 * When a cycle is present systemd detects and breaks it on *every* boot, so a
 * single fresh boot journal is a deterministic signal. We reboot first to make
 * sure the boot-transaction lines are in the journal we inspect (journald is
 * volatile and can rotate early lines away on a long-lived boot).
 */
module.exports = {
	title: 'systemd ordering tests',
	tests: [
		{
			title: 'boot transaction is free of ordering cycles',
			run: async function(test) {
				test.comment('rebooting to capture a fresh boot transaction...');
				await this.worker.rebootDut(this.link);

				// grep exits 1 when there is no match (the healthy case);
				// `|| true` keeps executeCommandInHostOS from retrying it as a
				// failed command.
				const offenders = await this.worker.executeCommandInHostOS(
					`journalctl -b --no-pager | grep -E 'ordering cycle|deleted to break ordering cycle' || true`,
					this.link,
				);
				test.is(
					offenders,
					'',
					'Boot journal should not report any broken systemd ordering cycle',
				);
			},
		},
		{
			// Supplementary invariant. Not a deterministic reproduction of the
			// bug (the cycle deletes a random victim, so a buggy build only
			// trips this on some boots), but it pins the catastrophic symptom
			// independently of journal retention.
			title: 'var-volatile.mount is active with a tmpfs at /var/volatile',
			run: async function(test) {
				const active = await this.worker.executeCommandInHostOS(
					`systemctl is-active var-volatile.mount`,
					this.link,
				);
				test.is(active, 'active', 'var-volatile.mount should be active');

				const fstype = await this.worker.executeCommandInHostOS(
					`findmnt -n -o FSTYPE /var/volatile`,
					this.link,
				);
				test.is(fstype, 'tmpfs', '/var/volatile should be backed by a tmpfs');
			},
		},
	],
};
