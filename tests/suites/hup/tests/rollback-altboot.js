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

		test.is(
			await this.worker.executeCommandInHostOS(
				`rm /mnt/sysroot/inactive/current/boot/init ; echo $?`,
				this.link,
			),
			'0',
			'Should delete mobynit to trigger rollback-altboot'
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
			'0',
			'Should have rollback-altboot-triggered in the state partition',
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

		test.is(
			await this.worker.getOSVersion(this.link),
			versionBeforeHup,
			`The OS version should have reverted to ${versionBeforeHup}`,
		);
	},
};
