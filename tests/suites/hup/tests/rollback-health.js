/*
 * Copyright 2021 balena
 *
 * @license Apache-2.0
 */

'use strict';

module.exports = {
	title: 'Rollback health tests',
	tests: [
		{
			title: 'Broken balena-engine',
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

				// reduce number of failures needed to trigger rollback
				test.comment(`Reducing timeout for rollback-health...`);
				await this.worker.executeCommandInHostOS(
						`sed -i -e "s/COUNT=.*/COUNT=3/g" -e "s/TIMEOUT=.*/TIMEOUT=20/g" $(find /mnt/sysroot/inactive/ | grep "bin/rollback-health")`,
						this.link,
					);

				// break balena-engine
				test.comment(`Breaking balena-engine to trigger rollback-health...`);
				await this.worker.executeCommandInHostOS(
						`ln -sf /dev/null $(find /mnt/sysroot/inactive/ | grep "usr/bin/balena-engine$")`,
						this.link,
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
						`test -f /mnt/state/rollback-health-triggered ; echo $?`,
						this.link,
					),
					'0',
					'Should have rollback-health-triggered in the state partition',
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
		},
		{
			title: 'Broken VPN',
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

				// reduce number of failures needed to trigger rollback
				test.comment(`Reducing timeout for rollback-health...`);
				await this.worker.executeCommandInHostOS(
						`sed -i -e "s/COUNT=.*/COUNT=3/g" -e "s/TIMEOUT=.*/TIMEOUT=20/g" $(find /mnt/sysroot/inactive/ | grep "bin/rollback-health")`,
						this.link,
					);

				// break openvpn
				test.comment(`Breaking openvpn to trigger rollback-health...`);
				await this.worker.executeCommandInHostOS(
						`ln -sf /dev/null $(find /mnt/sysroot/inactive/ | grep "bin/openvpn$")`,
						this.link,
					);

				test.comment(
					`Pretend VPN was previously active for unmanaged OS suite...`,
				);
				await this.worker.executeCommandInHostOS(
						`sed 's/BALENAOS_ROLLBACK_VPNONLINE=0/BALENAOS_ROLLBACK_VPNONLINE=1/' -i /mnt/state/rollback-health-variables && sync -f /mnt/state`,
						this.link,
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
						`test -f /mnt/state/rollback-health-triggered ; echo $?`,
						this.link,
					),
					'0',
					'Should have rollback-health-triggered in the state partition',
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
		},
	],
};
