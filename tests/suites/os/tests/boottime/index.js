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
	title: 'Boot time constraint',
	tests: [
		{
			title: 'Boot time to default target',
			run: async function(test) {
				const testName = `boot_time`
				await this.utils.waitUntil( async () => {
					return (
						(await this.worker.executeCommandInHostOS(
							`systemctl list-jobs`,
							this.link
						)) == 'No jobs running.'
					);
				}, false);
				let bootTime = await this.worker.executeCommandInHostOS(
						'systemd-analize time',
						this.link)
				const repo = await fs.mkdtemp(path.join(os.tmpdir(), 'leviathan-'), (err, repoPath) => {
					return git.Clone(
						this.suite.constraintsRepo,
						repoPath
					).then( (repo, repoPath) => {
						fs.pathExists(path.join(repoPath,fileName))
							.then( exists => {
								if (exists) {
									/* Compare with last result */
									return checkTimeConstraint(repo, testName, this.suite.version, bootTime)
								} else {
									/* Compare with last release */
									return lastOSRelease(repo, this.suite.version).then( (lastRelease) => {
										return checkTimeConstraint(repo, testName, lastRelease, bootTime).then( (repoPath, fileName) => {
											return fs.ensureFile(path.join(repoPath,fileName)).then( (repo, testName, version, bootTime) => {
												return addTimeConstraint(repo, filePath, version, bootTime)
											})
										})
									})
								}
							})
					})
				})
			},
		},
	],
};


