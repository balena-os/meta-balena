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
				await this.context
					.get()
					.hup.initDUT(this, test, this.context.get().link);

				const versionBeforeHup = await this.context
					.get()
					.worker.getOSVersion(this.context.get().link);

				test.comment(`OS version before HUP: ${versionBeforeHup}`);

				await this.context
					.get()
					.hup.doHUP(
						this,
						test,
						'local',
						this.context.get().hupOs.image.path,
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

				// break balena-engine
				test.comment(`Breaking balena-engine to trigger rollback-health...`);
				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`ln -sf /dev/null $(find /mnt/sysroot/inactive/ | grep "usr/bin/balena-engine$")`,
						this.context.get().link,
					);

				await this.context.get().worker.rebootDut(this.context.get().link);

				// reboots should be finished when breadcrumbs are gone and service is inactive
				// check every 30s for 5 min since we are expecting multiple reboots
				test.comment(`Waiting for rollback-health.service to be inactive...`);
				await this.context.get().utils.waitUntil(
					async () => {
						return (
							(await this.context
								.get()
								.worker.executeCommandInHostOS(
									`systemctl is-active rollback-health.service || test ! -f /mnt/state/rollback-health-breadcrumb`,
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
							`test -f /mnt/state/rollback-health-triggered ; echo $?`,
							this.context.get().link,
						),
					'0',
					'There should be a rollback-health-triggered file in the state partition',
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
							`test -f /mnt/state/rollback-health-failed ; echo $?`,
							this.context.get().link,
						),
					'1',
					'There should NOT be a rollback-health-failed file in the state partition',
				);
			},
		},
		{
			title: 'Broken VPN',
			run: async function(test) {
				await this.context
					.get()
					.hup.initDUT(this, test, this.context.get().link);

				const versionBeforeHup = await this.context
					.get()
					.worker.getOSVersion(this.context.get().link);

				test.comment(`OS version before HUP: ${versionBeforeHup}`);

				await this.context
					.get()
					.hup.doHUP(
						this,
						test,
						'local',
						this.context.get().hupOs.image.path,
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

				// break openvpn
				test.comment(`Breaking openvpn to trigger rollback-health...`);
				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`ln -sf /dev/null $(find /mnt/sysroot/inactive/ | grep "bin/openvpn$")`,
						this.context.get().link,
					);

				test.comment(
					`Pretend VPN was previously active for unmanaged OS suite...`,
				);
				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`sed 's/BALENAOS_ROLLBACK_VPNONLINE=0/BALENAOS_ROLLBACK_VPNONLINE=1/' -i /mnt/state/rollback-health-variables && sync -f /mnt/state`,
						this.context.get().link,
					);

				await this.context.get().worker.rebootDut(this.context.get().link);

				// reboots should be finished when breadcrumbs are gone and service is inactive
				// check every 30s for 5 min since we are expecting multiple reboots
				test.comment(`Waiting for rollback-health.service to be inactive...`);
				await this.context.get().utils.waitUntil(
					async () => {
						return (
							(await this.context
								.get()
								.worker.executeCommandInHostOS(
									`systemctl is-active rollback-health.service || test ! -f /mnt/state/rollback-health-breadcrumb`,
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
							`test -f /mnt/state/rollback-health-triggered ; echo $?`,
							this.context.get().link,
						),
					'0',
					'There should be a rollback-health-triggered file in the state partition',
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
							`test -f /mnt/state/rollback-health-failed ; echo $?`,
							this.context.get().link,
						),
					'1',
					'There should NOT be a rollback-health-failed file in the state partition',
				);
			},
		},
	],
};
