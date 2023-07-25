/* Copyright 2022 balena
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
	title: 'Engine healthcheck tests',
	tests: [
		{
			// Tests if the Engine recovers after being killed by Systemd's watchdog.
			title: 'Engine watchdog recovery',
			run: async function (test) {
				// Decrease the watchdog timeout to make the test run quicker.
				await this.utils.waitUntil(async() => {
					test.comment('Decreasing watchdog timeout...');
					return await this.worker.executeCommandInHostOS(
						`mkdir -p /run/systemd/system/balena.service.d &&
						{
							cat <<- EOF > /run/systemd/system/balena.service.d/override.conf
							[Service]
							WatchdogSec=15
							EOF
						} &&
						systemctl daemon-reload &&
						systemctl restart balena &&
						echo $?
						`,
						this.link,
					) === "0";
				}, false, 5, 500 )
		
				test.ok(true, 'Watchdog timeout should have been decreased');

				// Make sure the Engine service is up and running.
				test.comment('Waiting for the Engine to start');
				await this.utils.waitUntil(async () => {
					return await this.context
						.get()
						.worker.executeCommandInHostOS(
							`systemctl is-active balena`,
							this.link,
						) === 'active';
				}, false, 60, 1000);

				// Just in case, ensure the watchdog hasn't killed the Engine yet.
				test.is(
					await this.worker.executeCommandInHostOS(
						`journalctl -u balena | grep -q "balena.service: Failed with result 'watchdog'" ; echo $?`,
						this.link,
					),
					'1',
					'Watchdog should not have kicked in yet',
				);

				// Stop containerd to force a watchdog timeout.
				test.is(
					await this.worker.executeCommandInHostOS(
						`kill -STOP $(pidof balena-engine-containerd) ; echo $?`,
						this.link,
					),
					'0',
					'Stopping containerd should succeed',
				);

				// Wait for the watchdog to kill the balenaEngine service.
				test.comment('Waiting for the watchdog to kill balenaEngine');
				await this.utils.waitUntil(async () => {
					return await this.context
						.get()
						.worker.executeCommandInHostOS(
							`journalctl -u balena | grep -q "balena.service: Failed with result 'watchdog'" ; echo $?`,
							this.link,
						) === '0';
				}, false, 60, 1000);

				// Wait until balenaEngine is up and running again.
				test.comment('Waiting for balenaEngine to be healthy again');
				await this.utils.waitUntil(async () => {
					return await this.context
						.get()
						.worker.executeCommandInHostOS(
							`systemctl is-active balena`,
							this.link,
						) === 'active';
				}, false, 60, 1000);
			},
		},
		{
			// Detects major performance regressions. This test was introduced
			// along with an order-of-magnitude performance improvement to the
			// health checks.
			title: 'Engine healthcheck performance',
			run: async function (test) {
				// Performance of healthchecks varies greatly between device
				// types. We thus run the test only for a few device types we
				// have collected execution data for, and skip for the rest.

				// This is the limit for running the health check 3 times.
				let limitSecs = 0.0;

				const deviceType = this.suite.deviceType.slug;
				switch (deviceType) {
					case 'raspberry-pi':
						// On an idle Pi Zero W, 150 executions:
						// - Old check: average of 17.1s per execution, max of 28.7s
						// - New check: average of 0.8s per execution, max of 1.8s
						limitSecs = 10.0;
						break;
					case 'raspberrypi0-2w-64':
						// On a idle Pi Zero 2 W, 150 executions:
						// - Old check: average of 4.1s per execution, max of 5.8s
						// - New check: average of 0.4s per execution, max of 0.9s
						limitSecs = 6.0;
						break;
					case 'raspberrypi3-64':
						// Don't have the full results for the Pi 3 at hand, but
						// (as expected) they were just a bit better than the Pi
						// Zero 2 W.
						limitSecs = 5.0;
						break;
					default:
						test.comment(`Skipping test on this device type: ${deviceType}`);
						return;
				}

				// Disable healthchecks to avoid interference with the "fake"
				// executions we'll do next.
				await this.utils.waitUntil(async() => {
					test.comment('Disabling the Engine healthchecks');
					return await this.worker.executeCommandInHostOS(
						`mkdir -p /run/systemd/system/balena.service.d &&
						{
							cat <<- EOF > /run/systemd/system/balena.service.d/override.conf
							[Service]
							Environment=BALENAD_HEALTHDOG_HEALTHCHECK=/bin/true
							EOF
						} &&
						systemctl daemon-reload &&
						systemctl restart balena &&
						echo $?
						`,
						this.link,
					) === '0';
				}, false, 5, 500)

				test.ok(true, 'Watchdog should have been disabled')

				// Make sure the Engine service is up and running.
				test.comment('Waiting for the Engine to start');
				await this.utils.waitUntil(async () => {
					return await this.context
						.get()
						.worker.executeCommandInHostOS(
							`systemctl is-active balena`,
							this.link,
						) === 'active';
				}, false, 30, 1000);

				// Time healthcheck execution. We measure multiple executions to
				// avoid false positives caused by unusually slow cases on the
				// long tail.
				const result = await this.worker.executeCommandInHostOS(
					`start=$(date +%s.%N)
					{
						/usr/lib/balena/balena-healthcheck &&
						/usr/lib/balena/balena-healthcheck &&
						/usr/lib/balena/balena-healthcheck
					} &> /dev/null
					if [ $? != "0" ]; then
						echo "error"
					else
						end=$(date +%s.%N)
						echo "$end - $start" | bc
					fi
					`,
					this.link,
				)

				test.ok(
					result != 'error',
					'Healthchecks are expected to succeed',
				);

				test.ok(
					Number(result) < limitSecs,
					`Healthchecks on a ${deviceType} should run in less than ${limitSecs}s, took ${result}s`
				);
			},
		},
	]
};
