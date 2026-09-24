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
	title: 'Uptime tests',
	tests: [
		{
			title: 'uptime reports elapsed time',
			run: async function(test) {
				// Capture stdout, stderr and the exit code in one shot so the
				// result does not depend on whether the worker rejects on a
				// non-zero exit. Provider-agnostic: passes for coreutils, busybox
				// or procps, since they all read /proc/uptime and print a load
				// average.
				const output = await this.context
					.get()
					.worker.executeCommandInHostOS(
						'uptime 2>&1; echo uptime_rc=$?',
						this.link,
					);

				test.match(
					output,
					/uptime_rc=0/,
					'uptime should exit 0',
				);

				test.match(
					output,
					/up\b.*load average:/,
					'uptime should print an elapsed time and load average',
				);

				// Regression guard for the coreutils 9.4 utmp BOOT_TIME breakage
				// (balena-os/meta-balena#3875): balenaOS has no usable BOOT_TIME
				// record, so a uptime that relies on it fails this way.
				test.notMatch(
					output,
					/couldn't get boot time/,
					'uptime should not fail to get boot time',
				);

				test.notMatch(
					output,
					/\?\?\?\?/,
					'uptime should not print the unknown-uptime placeholder',
				);
			},
		},
	],
};
