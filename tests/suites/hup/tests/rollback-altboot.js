/*
 * Copyright 2021 balena
 *
 * @license Apache-2.0
 */

'use strict';

module.exports = {
	title: 'Rollback altboot (broken init) test',
	run: async function(test) {
		await this.context.get().hup.initDUT(this, test, this.context.get().link);

		const versionBeforeHup = await this.context
			.get()
			.worker.getOSVersion(this.context.get().link);

		test.comment(`OS version before HUP: ${versionBeforeHup}`);

		await this.context
			.get()
			.hup.doHUP(
				this,
				test,
				'image',
				this.context.get().hup.payload,
				this.context.get().link,
			);

		// break init
		test.comment(`Breaking init to trigger rollback-altboot...`);
		await this.context
			.get()
			.worker.executeCommandInHostOS(
				`rm /mnt/sysroot/inactive/current/boot/init`,
				this.context.get().link,
			);

		await this.context.get().worker.rebootDut(this.context.get().link);

		// reboots should be finished when breadcrumbs are gone and service is inactive
		// check every 30s for 5 min since we are expecting multiple reboots
		test.comment(`Waiting for rollback-altboot.service to be inactive...`);
		await this.context.get().utils.waitUntil(
			async () => {
				return (
					(await this.context
						.get()
						.worker.executeCommandInHostOS(
							`systemctl is-active rollback-altboot.service || test ! -f /mnt/state/rollback-altboot-breadcrumb`,
							this.context.get().link,
						)) === `inactive`
				);
			},
			false,
			10,
			30000,
		);

		test.is(
			await this.context.get().worker.getOSVersion(this.context.get().link),
			versionBeforeHup,
			`The OS version should have reverted to ${versionBeforeHup}`,
		);

		// 0 means file exists, 1 means file does not exist
		test.is(
			await this.context
				.get()
				.worker.executeCommandInHostOS(
					`test -f /mnt/state/rollback-altboot-triggered ; echo $?`,
					this.context.get().link,
				),
			'0',
			'There should be a rollback-altboot-triggered file in the state partition',
		);

		// 0 means file exists, 1 means file does not exist
		test.is(
			await this.context
				.get()
				.worker.executeCommandInHostOS(
					`test -f /mnt/state/rollback-health-triggered ; echo $?`,
					this.context.get().link,
				),
			'1',
			'There should NOT be a rollback-health-triggered file in the state partition',
		);

		// 0 means file exists, 1 means file does not exist
		test.is(
			await this.context
				.get()
				.worker.executeCommandInHostOS(
					`test -f /mnt/state/rollback-health-failed ; echo $?`,
					this.context.get().link,
				),
			'1',
			'There should NOT be a rollback-health-failed file in the state partition',
		);
	},
};
