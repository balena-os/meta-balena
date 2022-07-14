/*
 * Copyright 2021 balena
 *
 * @license Apache-2.0
 */

'use strict';

module.exports = {
	title: 'Smoke tests',
	tests: [
		{
			title: 'HUP from previous release',
			run: async function (test) {
				await this.hup.initDUT(this, test, this.link);

				const versionBeforeHup = await this.worker.getOSVersion(this.link);

				test.comment(`OS version before HUP: ${versionBeforeHup}`);

				// Check for under-voltage before HUP, in the old OS
				await this.hup.checkUnderVoltage(this, test);

				test.is(
					await this.worker.executeCommandInHostOS(
						`balena volume create hello-world`,
						this.link,
					),
					'hello-world',
					'Should create hello-world volume'
				);

				await this.hup.doHUP(
					this,
					test,
					'local',
					this.hupOs.image.path,
					this.link,
				);

				test.is(
					await this.worker.executeCommandInHostOS(
						`sed -i -e "s/COUNT=.*/COUNT=3/g" -e "s/TIMEOUT=.*/TIMEOUT=10/g" $(find /mnt/sysroot/inactive/ | grep "bin/rollback-health") ; echo $?`,
						this.link,
					),
					'0',	// does not confirm that sed replaced the values, only that the command did not fail
					'Should reduce rollback-health timeout to 3x10s'
				);

				await this.worker.rebootDut(this.link);

				// 0 means file exists, 1 means file does not exist
				await test.resolves(
					this.utils.waitUntil(async () => {
						return this.worker.executeCommandInHostOS(
							`test -f /mnt/state/rollback-health-breadcrumb ; echo $?`,
							this.link,
						).then(out => {
							return out === '1';
						})
					}, false, 5 * 60, 1000),	// 5 min
					'Should not have rollback-health-breadcrumb in the state partition'
				);

				// 0 means file exists, 1 means file does not exist
				test.is(
					await this.worker.executeCommandInHostOS(
						`test -f /mnt/state/rollback-altboot-breadcrumb ; echo $?`,
						this.link,
					),
					'1',
					'Should not have rollback-altboot-breadcrumb in the state partition',
				);

				// 0 means file exists, 1 means file does not exist
				test.is(
					await this.worker.executeCommandInHostOS(
						`test -f /mnt/state/rollback-altboot-triggered ; echo $?`,
						this.link,
					),
					'1',
					'Should not have rollback-altboot-triggered in the state partition',
				);

				// 0 means file exists, 1 means file does not exist
				test.is(
					await this.worker.executeCommandInHostOS(
						`test -f /mnt/state/rollback-health-triggered ; echo $?`,
						this.link,
					),
					'1',
					'Should not have rollback-health-triggered in the state partition',
				);

				// 0 means file exists, 1 means file does not exist
				test.is(
					await this.worker.executeCommandInHostOS(
						`test -f /mnt/state/rollback-health-failed ; echo $?`,
						this.link,
					),
					'1',
					'Should not have rollback-health-failed in the state partition',
				);

				const versionAfterHup = await this.worker.getOSVersion(this.link);

				test.comment(
					`Successful HUP from ${versionBeforeHup} to ${versionAfterHup}`,
				);

				test.is(
					await this.worker.executeCommandInHostOS(
						`balena volume inspect hello-world 1>/dev/null 2>&1; echo $?`,
						this.link,
					),
					'0',
					'Volume should not be lost during HUP',
				);

				// Check for under-voltage after HUP, in the new OS
				await this.hup.checkUnderVoltage(this, test);
			},
		},
		{
			title: 'HUP from this release',
			run: async function (test) {
				const versionBeforeHup = await this.worker.getOSVersion(this.link);

				test.comment(`OS version before HUP: ${versionBeforeHup}`);

				test.is(
					await this.worker.executeCommandInHostOS(
						`balena volume create hello-world`,
						this.link,
					),
					'hello-world',
					'Should create hello-world volume'
				);

				await this.hup.doHUP(
					this,
					test,
					'local',
					this.hupOs.image.path,
					this.link,
				);

				test.is(
					await this.worker.executeCommandInHostOS(
						`sed -i -e "s/COUNT=.*/COUNT=3/g" -e "s/TIMEOUT=.*/TIMEOUT=10/g" $(find /mnt/sysroot/inactive/ | grep "bin/rollback-health") ; echo $?`,
						this.link,
					),
					'0',	// does not confirm that sed replaced the values, only that the command did not fail
					'Should reduce rollback-health timeout to 3x10s'
				);

				await this.worker.rebootDut(this.link);

				// 0 means file exists, 1 means file does not exist
				await test.resolves(
					this.utils.waitUntil(async () => {
						return this.worker.executeCommandInHostOS(
							`test -f /mnt/state/rollback-health-breadcrumb ; echo $?`,
							this.link,
						).then(out => {
							return out === '1';
						})
					}, false, 5 * 60, 1000),	// 5 min
					'Should not have rollback-health-breadcrumb in the state partition'
				);

				// 0 means file exists, 1 means file does not exist
				test.is(
					await this.worker.executeCommandInHostOS(
						`test -f /mnt/state/rollback-altboot-breadcrumb ; echo $?`,
						this.link,
					),
					'1',
					'Should not have rollback-altboot-breadcrumb in the state partition',
				);

				// 0 means file exists, 1 means file does not exist
				test.is(
					await this.worker.executeCommandInHostOS(
						`test -f /mnt/state/rollback-altboot-triggered ; echo $?`,
						this.link,
					),
					'1',
					'Should not have rollback-altboot-triggered in the state partition',
				);

				// 0 means file exists, 1 means file does not exist
				test.is(
					await this.worker.executeCommandInHostOS(
						`test -f /mnt/state/rollback-health-triggered ; echo $?`,
						this.link,
					),
					'1',
					'Should not have rollback-health-triggered in the state partition',
				);

				// 0 means file exists, 1 means file does not exist
				test.is(
					await this.worker.executeCommandInHostOS(
						`test -f /mnt/state/rollback-health-failed ; echo $?`,
						this.link,
					),
					'1',
					'Should not have rollback-health-failed in the state partition',
				);

				const versionAfterHup = await this.worker.getOSVersion(this.link);

				test.comment(
					`Successful HUP from ${versionBeforeHup} to ${versionAfterHup}`,
				);

				test.is(
					await this.worker.executeCommandInHostOS(
						`balena volume inspect hello-world 1>/dev/null 2>&1; echo $?`,
						this.link,
					),
					'0',
					'Volume should not be lost during HUP',
				);
			},
		},
	],
};
