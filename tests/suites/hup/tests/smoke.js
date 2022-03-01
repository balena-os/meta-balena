/*
 * Copyright 2021 balena
 *
 * @license Apache-2.0
 */

'use strict';

module.exports = {
	title: 'Smoke test',
	run: async function(test) {
		await this.hup.initDUT(this, test, this.link);

		const versionBeforeHup = await this.worker.getOSVersion(this.link);

		test.comment(`OS version before HUP: ${versionBeforeHup}`);

		// Check for under-voltage before HUP, in the old OS
		await this.hup.checkUnderVoltage(
				this,
				test
			);

		await this.worker.executeCommandInHostOS(
				`balena volume create hello-world`,
				this.link,
			);

		await this.hup.doHUP(
				this,
				test,
				'local',
				this.hupOs.image.path,
				this.link,
			);

		// reduce number of failures needed to trigger rollback
		test.comment(`Reducing timeout for rollback-health...`);
		await this.worker.executeCommandInHostOS(
				`sed -i -e "s/COUNT=.*/COUNT=3/g" -e "s/TIMEOUT=.*/TIMEOUT=20/g" $(find /mnt/sysroot/inactive/ | grep "bin/rollback-health")`,
				this.link,
			);

		await this.worker.rebootDut(this.link);

		// check every 5s for 2min
		// 0 means file exists, 1 means file does not exist
		test.comment(`Waiting for rollback-health-breadcrumb to be cleaned up...`);
		await this.utils.waitUntil(
			async () => {
				return (
					(await this.worker.executeCommandInHostOS(
							`test -f /mnt/state/rollback-health-breadcrumb ; echo $?`,
							this.link,
						)) === `1`
				);
			},
			false,
			24,
			5000,
		);

		// 0 means file exists, 1 means file does not exist
		test.is(
			await this.worker.executeCommandInHostOS(
					`test -f /mnt/state/rollback-altboot-triggered ; echo $?`,
					this.link,
				),
			'1',
			'There should NOT be a rollback-altboot-triggered file in the state partition',
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
		await this.hup.checkUnderVoltage(
				this,
				test
			);
	},
};
