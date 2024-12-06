/*
 * Copyright 2021 balena
 *
 * @license Apache-2.0
 */

'use strict';


module.exports = {
	title: 'Rollback tests',
	run: async function (test) {
		await this.hup.initDUT(this, test, this.link);
	},
	tests: [
		{
			title: 'Broken balena-engine',
			run: async function (test) {
				const origVersion = await this.worker.getOSVersion(this.link);

				const activePartition = await this.worker.executeCommandInHostOS(
					`findmnt --noheadings --canonicalize --output SOURCE /mnt/sysroot/active`,
					this.link,
				);

				await this.hup.doHUP(
					this,
					test,
					'local',
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

				test.is(
					await this.worker.executeCommandInHostOS(
						`ln -sf /dev/null $(find /mnt/sysroot/inactive/ | grep "usr/bin/balena-engine$") ; echo $?`,
						this.link,
					),
					'0',
					'Should replace balena-engine with a null link to trigger rollback-health'
				);

				await this.worker.rebootDut(this.link);

				await test.resolves(
					this.utils.waitUntil(async () => {
						return this.worker.executeCommandInHostOS(
							`findmnt --noheadings --canonicalize --output SOURCE /mnt/sysroot/active`,
							this.link,
						).then(out => {
							return out === activePartition;
						})
					}, false, 5 * 60, 1000),	// 5 min
					'Should have rolled back to the original root partition'
				);

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
					origVersion,
					`Should have rolled back to the original OS version`,
				);
			},
		},
		{
			title: 'Broken VPN',
			run: async function (test) {
				const origVersion = await this.worker.getOSVersion(this.link);

				const activePartition = await this.worker.executeCommandInHostOS(
					`findmnt --noheadings --canonicalize --output SOURCE /mnt/sysroot/active`,
					this.link,
				);

				await this.hup.doHUP(
					this,
					test,
					'local',
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

				test.is(
					await this.worker.executeCommandInHostOS(
						`ln -sf /dev/null $(find /mnt/sysroot/inactive/ | grep "bin/openvpn$") ; echo $?`,
						this.link,
					),
					'0',
					'Should replace openvpn with a null link to trigger rollback-health'
				);

				test.is(
					await this.worker.executeCommandInHostOS(
						`sed 's/BALENAOS_ROLLBACK_VPNONLINE=0/BALENAOS_ROLLBACK_VPNONLINE=1/' -i /mnt/state/rollback-health-variables && sync -f /mnt/state ; echo $?`,
						this.link,
					),
					'0',	// does not confirm that sed replaced the values, only that the command did not fail
					'Should override vpn online status so failed openvpn is not ignored'
				);

				await this.worker.rebootDut(this.link);

				await test.resolves(
					this.utils.waitUntil(async () => {
						return this.worker.executeCommandInHostOS(
							`findmnt --noheadings --canonicalize --output SOURCE /mnt/sysroot/active`,
							this.link,
						).then(out => {
							return out === activePartition;
						})
					}, false, 5 * 60, 1000),	// 5 min
					'Should have rolled back to the original root partition'
				);

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
					origVersion,
					`Should have rolled back to the original OS version`,
				);
			},
		},
		{
			title: 'Rollback altboot (broken init) test',
			run: async function (test) {
				const origVersion = await this.worker.getOSVersion(this.link);

				const activePartition = await this.worker.executeCommandInHostOS(
					`findmnt --noheadings --canonicalize --output SOURCE /mnt/sysroot/active`,
					this.link,
				);

				await this.hup.doHUP(
					this,
					test,
					'local',
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

				await this.utils.waitUntil(async () => {
					console.log(`Waiting for rollback-altboot service to be inactive...`)	
					let state = await this.worker.executeCommandInHostOS(
						`systemctl is-active rollback-altboot || true`,
						this.link
					)
					console.log(state)
					return (state === "inactive");
				})

				await this.utils.waitUntil(async () => {
					console.log(`Waiting for rollback-health service to be inactive...`)	
					let state = await this.worker.executeCommandInHostOS(
						`systemctl is-active rollback-health || true`,
						this.link
					)
					console.log(state)
					return (state === "inactive");
				})
				
				await test.resolves(
					this.utils.waitUntil(async () => {
						return this.worker.executeCommandInHostOS(
							`findmnt --noheadings --canonicalize --output SOURCE /mnt/sysroot/active`,
							this.link,
						).then(out => {
							return out === activePartition;
						})
					}, false, 5 * 60, 1000),	// 5 min
					'Should have rolled back to the original root partition'
				);

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
					origVersion,
					`Should have rolled back to the original OS version`,
				);
			},
		}
	],
};
