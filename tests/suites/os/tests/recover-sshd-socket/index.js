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
	title: 'sshd.socket burst protection recovery tests',
	tests: [
		{
			title: 'Recovery timer is active',
			run: async function (test) {
				test.comment('Checking recover-sshd-socket.timer is active...');
				await this.systemd.waitForServiceState(
					'recover-sshd-socket.timer',
					'active',
					this.link,
				);
				const result = await this.worker.executeCommandInHostOS(
					'systemctl is-active recover-sshd-socket.timer',
					this.link,
				);
				test.is(
					result,
					'active',
					'recover-sshd-socket.timer should be active',
				);
			},
		},
		{
			title: 'sshd.socket recovers after burst protection',
			run: async function (test) {
				// Lower trigger limits and speed up recovery timer so the
				// test completes quickly without waiting 15 minutes.
				test.comment('Installing drop-in overrides...');
				await this.utils.waitUntil(async () => {
					return await this.worker.executeCommandInHostOS(
						`mkdir -p /run/systemd/system/sshd.socket.d &&
						{
							cat <<- EOF > /run/systemd/system/sshd.socket.d/override.conf
							[Socket]
							TriggerLimitBurst=5
							TriggerLimitIntervalSec=5s
							EOF
						} &&
						mkdir -p /run/systemd/system/recover-sshd-socket.timer.d &&
						{
							cat <<- EOF > /run/systemd/system/recover-sshd-socket.timer.d/override.conf
							[Timer]
							OnCalendar=
							OnCalendar=*:*:0/10
							EOF
						} &&
						systemctl daemon-reload &&
						systemctl restart sshd.socket recover-sshd-socket.timer &&
						echo done`,
						this.link,
					) === 'done';
				}, false, 5, 500);
				test.ok(true, 'Drop-in overrides should be installed');

				// Rotate journal for a clean baseline.
				await this.worker.executeCommandInHostOS(
					'journalctl --rotate --vacuum-time=1s',
					this.link,
				);

				// Trigger burst protection AND verify it in the same SSH
				// session. With Accept=yes, stopping sshd.socket kills no
				// existing connections — only prevents new ones. So this
				// single session survives the burst it triggers.
				test.comment('Triggering burst protection...');
				const result = await this.worker.executeCommandInHostOS(
					[
						'for i in $(seq 1 20); do',
						'  (exec 3<>/dev/tcp/127.0.0.1/22222 && exec 3>&-) 2>/dev/null &',
						'done',
						'wait',
						'sleep 2',
						'systemctl show -p Result --value sshd.socket',
					].join('\n'),
					this.link,
				);
				test.is(
					result,
					'trigger-limit-hit',
					'sshd.socket should be stopped by burst protection',
				);

				// Wait for recovery. The framework retries SSH
				// connections, so once the timer restarts the socket the
				// next executeCommandInHostOS call reconnects.
				test.comment('Waiting for sshd.socket to recover...');
				await this.utils.waitUntil(async () => {
					return await this.context
						.get()
						.worker.executeCommandInHostOS(
							'systemctl is-active sshd.socket',
							this.link,
						) === 'active';
				}, false, 60, 1000);

				test.is(
					await this.worker.executeCommandInHostOS(
						'systemctl is-active sshd.socket',
						this.link,
					),
					'active',
					'sshd.socket should be active after recovery',
				);

				// Verify the recovery service actually ran.
				test.comment('Checking journal for recovery message...');
				test.match(
					await this.worker.executeCommandInHostOS(
						'journalctl -u recover-sshd-socket.service',
						this.link,
					),
					/trigger rate limit.*restarting/,
					'Recovery service should log that it restarted sshd.socket',
				);

				// Cleanup: remove drop-ins and restore defaults.
				test.comment('Cleaning up overrides...');
				await this.worker.executeCommandInHostOS(
					[
						'rm -rf /run/systemd/system/sshd.socket.d',
						'rm -rf /run/systemd/system/recover-sshd-socket.timer.d',
						'systemctl daemon-reload',
						'systemctl reset-failed sshd.socket',
						'systemctl restart sshd.socket recover-sshd-socket.timer',
					].join(' && '),
					this.link,
				);
			},
		},
		{
			title: 'Recovery ignores healthy sockets',
			run: async function (test) {
				// Rotate journal for a clean baseline.
				await this.worker.executeCommandInHostOS(
					'journalctl --rotate --vacuum-time=1s',
					this.link,
				);

				// Verify sshd.socket is healthy first.
				const socketResult = await this.worker.executeCommandInHostOS(
					'systemctl show -p Result --value sshd.socket',
					this.link,
				);
				test.is(
					socketResult,
					'success',
					'sshd.socket should have Result=success when healthy',
				);

				// Manually trigger the recovery service.
				test.comment('Running recover-sshd-socket.service on a healthy socket...');
				await this.worker.executeCommandInHostOS(
					'systemctl start recover-sshd-socket.service',
					this.link,
				);

				// Socket should still be active.
				test.is(
					await this.worker.executeCommandInHostOS(
						'systemctl is-active sshd.socket',
						this.link,
					),
					'active',
					'sshd.socket should remain active',
				);

				// Journal should NOT contain the restart message.
				test.is(
					await this.worker.executeCommandInHostOS(
						`journalctl -u recover-sshd-socket.service | grep -q "trigger rate limit.*restarting"; echo $?`,
						this.link,
					),
					'1',
					'Recovery service should not restart a healthy socket',
				);
			},
		},
	],
};
