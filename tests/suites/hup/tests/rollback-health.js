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

				// reboots should be finished when breadcrumbs are gone and service is inactive
				// check every 30s for 5 min since we are expecting multiple reboots
				test.comment(`Waiting for rollback-health.service to be inactive...`);
				await this.utils.waitUntil(
					async () => {
						return (
							(await this.worker.executeCommandInHostOS(
									`systemctl is-active rollback-health.service || test ! -f /mnt/state/rollback-health-breadcrumb`,
									this.link,
								)) === `inactive`
						);
					},
					false,
					5 * 60,
					1000,
				);

				test.is(
					await this.worker.getOSVersion(this.link),
					versionBeforeHup,
					`The OS version should have reverted to ${versionBeforeHup}`,
				);

				// 0 means file exists, 1 means file does not exist
				test.is(
					await this.worker.executeCommandInHostOS(
							`test -f /mnt/state/rollback-health-triggered ; echo $?`,
							this.link,
						),
					'0',
					'There should be a rollback-health-triggered file in the state partition',
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
							`test -f /mnt/state/rollback-health-failed ; echo $?`,
							this.link,
						),
					'1',
					'There should NOT be a rollback-health-failed file in the state partition',
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

				// reboots should be finished when breadcrumbs are gone and service is inactive
				// check every 30s for 5 min since we are expecting multiple reboots
				test.comment(`Waiting for rollback-health.service to be inactive...`);
				await this.utils.waitUntil(
					async () => {
						return (
							(await this.worker.executeCommandInHostOS(
									`systemctl is-active rollback-health.service || test ! -f /mnt/state/rollback-health-breadcrumb`,
									this.link,
								)) === `inactive`
						);
					},
					false,
					5 * 60,
					1000,
				);

				test.is(
					await this.worker.getOSVersion(this.link),
					versionBeforeHup,
					`The OS version should have reverted to ${versionBeforeHup}`,
				);

				// 0 means file exists, 1 means file does not exist
				test.is(
					await this.worker.executeCommandInHostOS(
							`test -f /mnt/state/rollback-health-triggered ; echo $?`,
							this.link,
						),
					'0',
					'There should be a rollback-health-triggered file in the state partition',
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
							`test -f /mnt/state/rollback-health-failed ; echo $?`,
							this.link,
						),
					'1',
					'There should NOT be a rollback-health-failed file in the state partition',
				);
			},
		},
	],
};
