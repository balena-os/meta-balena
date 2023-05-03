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
let migrateRequested = false

module.exports = {
	title: 'Installer migrate tests',
	tests: [
		{
			title: 'Installer used migrator module',
			run: async function(test) {
				let skip = true;
				try {
					if (this.os.configJson.installer.migrate.force) {
						skip = false;
					}
				} catch (e) {
					// will be skipped
				}
				if (skip) {
						test.comment("No migration requested - skipping")
				} else {
						await test.resolves(
							this.utils.waitUntil(async () => {
								return this.worker.executeCommandInHostOS(
									`test /mnt/boot/migration_* ; echo $?`,
									this.link,
								).then(out => {
									return out === '0';
							})
						}, false, 5 * 60, 1000),  // 5 min
							'Should have a single migration log file in boot partition'
						);
						test.equal(
							await this.worker.executeCommandInHostOS(
									'find /mnt/boot -maxdepth 1 -name migration_* | xargs grep -q "Running migration"; echo $?',
									this.link,
								),
								'0',
								'Migration execution confirmed in log file'
						);
				}
			},
		},
	],
};
