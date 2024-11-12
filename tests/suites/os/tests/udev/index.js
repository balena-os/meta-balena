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
	title: 'udev tests',
	tests: [
		{
			title: 'Ramdisks, zram and loop devices are not scanned for rootfs',
			run: async function(test) {
				// This is an artificial condition - it is difficult to say at any moment whether
				// all the devices have been brought up as some of them may take longer than others.
				// This waits for the engine to start which should mean the system is up and running.
				await this.systemd.waitForServiceState('balena.service', 'active', this.link);

				test.is(
					await this.worker.executeCommandInHostOS(
							[
								`journalctl`, `-u`, `systemd-udevd.service`,
								`|`, `grep`, `"Failed to substitute variable"`,
								`>`, `/dev/null`, `2>&1`, `||`, `echo`, `"pass"`,
							],
							this.link,
						),
					'pass',
					'Udev logs have no warnings from scanning ramdisks, zram or loop devices for rootfs.',
				);
			},
		},
		{
			title: 'by-state links are created',
			run: async function(test) {
				const links = [
					'active',
					'inactive',
					'resin-data',
					'resin-rootA',
					'resin-rootB',
					'resin-state',
				];

				const rootDisk = await this.worker.executeCommandInHostOS(
					`eval $(lsblk -oMOUNTPOINT,PKNAME -P | grep 'MOUNTPOINT="/mnt/sysroot/active"'); echo $PKNAME`,
					this.link
				);

				test.comment(`active root is on /dev/${rootDisk}`);

				await test.resolves(
					this.worker.executeCommandInHostOS(
						`for l in ${links.join(' ')}; do test -L "/dev/disk/by-state/$l"; done`,
						this.link
					),
					'All required by-state links have been created'
				);
			}
		},
		{
			title: 'rootfs by-state links are unique',
			run: async function(test) {
				return test.resolves(
					this.worker.executeCommandInHostOS(
						`test /dev/disk/by-state/active != /dev/disk/by-state/inactive`,
						this.link
					),
					'Links are unique'
				);
			},
		},
	],
};
