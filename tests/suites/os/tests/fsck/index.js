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

const Promise = require('bluebird');

module.exports = {
	title: 'fsck.ext4 tests',
	tests: [
		{
			title: 'ext4 filesystems are checked on boot',
			run: async function(test) {
				async function markDirty(that, label) {
					return that.worker.executeCommandInHostOS(
							['tune2fs', '-E', 'force_fsck',
								`/dev/disk/by-label/${label}`
							].join(' '),
							that.link
						);
				}

				async function getFilesystemState(that, label) {
						return that.worker.executeCommandInHostOS(
							['tune2fs', '-l', `/dev/disk/by-label/${label}`,
								'|', 'grep', '"Filesystem state"',
								'|', 'cut', '-d:', '-f2',
								'|', 'xargs'
							].join(' '),
							that.link
						);
				}

				// Exclude the boot partition for now, as it doesn't have metadata to
				// track when it was last checked, nor can we check the dirty bit while
				// it's mounted
				let diskLabels = [
					'resin-rootA',
					'resin-rootB',
					'resin-state',
					'resin-data',
				];

				return Promise.map(diskLabels, (label) => {
					return markDirty(this, label).then(() => {
						return getFilesystemState(this, label).then((state) => {
							let expectedState = 'clean with errors';
							test.is(
								state,
								expectedState,
								`Filesystem state for ${label} should be '${expectedState}'`
							);
						});
					});
				}).then(() => {
					test.comment('Filesystems have been marked dirty');
					return this.worker.rebootDut(this.link);
				}).then(() => {
					return Promise.map(diskLabels, (label) => {
						return getFilesystemState(this, label).then((state) => {
							let expectedState = 'clean';
							test.is(
								state,
								expectedState,
								`Filesystem state for ${label} should be '${expectedState}'`
							);
						});
					});
				});
			}
		}
	]
};
