/*
 * Copyright 2021 balena
 *
 * @license Apache-2.0
 */

'use strict';

module.exports = {
	title: 'Smoke test',
	run: async function(test) {
		await this.context.get().hup.initDUT(this, test, this.context.get().link);

		const versionBeforeHup = await this.context
			.get()
			.worker.getOSVersion(this.context.get().link);

		test.comment(`OS version before HUP: ${versionBeforeHup}`);

		// Check for under-voltage before HUP, in the old OS
		await this.context
			.get()
			.hup.checkUnderVoltage(
				this,
				test
			);

		await this.context
			.get()
			.worker.executeCommandInHostOS(
				`balena volume create hello-world`,
				this.context.get().link,
			);

		await this.context
			.get()
			.hup.doHUP(
				this,
				test,
				'image',
				this.context.get().hup.payload,
				this.context.get().link,
			);

		// reduce number of failures needed to trigger rollback
		test.comment(`Reducing timeout for rollback-health...`);
		await this.context
			.get()
			.worker.executeCommandInHostOS(
				`sed -i -e "s/COUNT=.*/COUNT=3/g" -e "s/TIMEOUT=.*/TIMEOUT=20/g" $(find /mnt/sysroot/inactive/ | grep "bin/rollback-health")`,
				this.context.get().link,
			);

		await this.context.get().worker.rebootDut(this.context.get().link);

		// check every 5s for 2min
		// 0 means file exists, 1 means file does not exist
		test.comment(`Waiting for rollback-health-breadcrumb to be cleaned up...`);
		await this.context.get().utils.waitUntil(
			async () => {
				return (
					(await this.context
						.get()
						.worker.executeCommandInHostOS(
							`test -f /mnt/state/rollback-health-breadcrumb ; echo $?`,
							this.context.get().link,
						)) === `1`
				);
			},
			false,
			24,
			5000,
		);

		// 0 means file exists, 1 means file does not exist
		test.is(
			await this.context
				.get()
				.worker.executeCommandInHostOS(
					`test -f /mnt/state/rollback-altboot-triggered ; echo $?`,
					this.context.get().link,
				),
			'1',
			'There should NOT be a rollback-altboot-triggered file in the state partition',
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

		const versionAfterHup = await this.context
			.get()
			.worker.getOSVersion(this.context.get().link);

		test.comment(
			`Successful HUP from ${versionBeforeHup} to ${versionAfterHup}`,
		);

		test.is(
			await this.context
				.get()
				.worker.executeCommandInHostOS(
					`balena volume inspect hello-world 1>/dev/null 2>&1; echo $?`,
					this.context.get().link,
				),
			'0',
			'Volume should not be lost during HUP',
		);

		// Check for under-voltage after HUP, in the new OS
		await this.context
			.get()
			.hup.checkUnderVoltage(
				this,
				test
			);
	},
};
