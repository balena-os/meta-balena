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

// Guard against systemd ordering cycles in the boot transaction.
module.exports = {
	title: 'systemd ordering tests',
	tests: [
		{
			title: 'boot transaction is free of ordering cycles',
			run: async function(test) {
				// The volatile journal can rotate early boot lines away.
				await this.worker.rebootDut(this.link);

				// Fail if journalctl fails; grep exits 1 on no match.
				const offenders = await this.worker.executeCommandInHostOS(
					`journal=$(journalctl -b --no-pager) && { echo "$journal" | grep -E 'ordering cycle|Unable to break cycle' || true; }`,
					this.link,
				);
				test.is(
					offenders,
					'',
					'Boot journal should not report any broken systemd ordering cycle',
				);
			},
		},
	],
};
