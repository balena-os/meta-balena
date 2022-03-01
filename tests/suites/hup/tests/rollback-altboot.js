/*
 * Copyright 2021 balena
 *
 * @license Apache-2.0
 */

'use strict';

module.exports = {
	title: 'Rollback altboot (broken init) test',
	run: async function(test) {
		await this.hup.initDUT(this, test, this.link);

		const versionBeforeHup = await this.worker.getOSVersion(this.link);

		test.comment(`OS version before HUP: ${versionBeforeHup}`);

		await this.hup.doHUP(
				this,
				test,
				'local',
				this.hupOs.image.path,
				this.link,
			);

		// break init
		test.comment(`Breaking init to trigger rollback-altboot...`);
		await this.worker.executeCommandInHostOS(
				`rm /mnt/sysroot/inactive/current/boot/init`,
				this.link,
			);

		await this.worker.rebootDut(this.link);

		// reboots should be finished when breadcrumbs are gone and service is inactive
		// check every 30s for 5 min since we are expecting multiple reboots
		test.comment(`Waiting for rollback-altboot.service to be inactive...`);
		await this.utils.waitUntil(
			async () => {
				return (
					(await this.worker.executeCommandInHostOS(
							`systemctl is-active rollback-altboot.service || test ! -f /mnt/state/rollback-altboot-breadcrumb`,
							this.link,
						)) === `inactive`
				);
			},
			false,
			10,
			30000,
		);

		test.is(
			await this.worker.getOSVersion(this.link),
			versionBeforeHup,
			`The OS version should have reverted to ${versionBeforeHup}`,
		);

		// 0 means file exists, 1 means file does not exist
		test.is(
			await this.worker.executeCommandInHostOS(
					`test -f /mnt/state/rollback-altboot-triggered ; echo $?`,
					this.link,
				),
			'0',
			'There should be a rollback-altboot-triggered file in the state partition',
		);

		// 0 means file exists, 1 means file does not exist
		test.is(
			await this.worker.executeCommandInHostOS(
					`test -f /mnt/state/rollback-health-triggered ; echo $?`,
					this.link,
				),
			'1',
			'There should NOT be a rollback-health-triggered file in the state partition',
		);

		// 0 means file exists, 1 means file does not exist
		test.is(
			await this.worker.executeCommandInHostOS(
					`test -f /mnt/state/rollback-health-failed ; echo $?`,
					this.link,
				),
			'1',
			'There should NOT be a rollback-health-failed file in the state partition',
		);
	},
};
