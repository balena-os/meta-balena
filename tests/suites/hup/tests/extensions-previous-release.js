/*
 * Copyright 2026 balena
 *
 * @license Apache-2.0
 */

'use strict';

const ext = require('../lib/extensions');
const seed = require('../lib/seed');

// balena-extension-manager log lines, read as observations only
const STALE_PASS = 'removing stale extensions';
const COMMIT_HOOKS_FAILED = 'commit hook.* failed';
// rollback-health logs the shorter prefix too, twice
const ALTBOOT_RECOVERY = 'altboot mode. Running hooks to recover bootfiles';

// SEED: the older OS. TGT: the build under test.
// The cases skip when SEED cannot run extensions.

// The oldest helios that stages overlays before an update
const MIN_HELIOS = [0, 28, 0];

const RUNTIME = 0;
const ACTIVE = 1;

const skipReason = (gate, level) => {
	if (gate.services.length === 0) {
		return 'No hostapp extension image staged for this build';
	}
	if (!gate.seedCapable) {
		return 'The previous release runs no helios that stages overlays (0.28.0 or later)';
	}
	if (level >= ACTIVE && !gate.activated) {
		return 'The extensions were not activated on the previous release';
	}
	return null;
};

module.exports = {
	title: 'Hostapp extension tests from a previous release',
	run: async function (test) {
		const services = Object.keys(ext.artifacts());

		const gate = {
			services: services,
			seedCapable: false,
			heliosVersion: '',
			seedVersion: '',
			tgtVersion: '',
			activated: false,
			images: {},
		};

		if (services.length === 0) {
			test.comment('Staged hostapp extensions: none');
			this.suite.context.set({ extensionsGate2: gate });
			return;
		}

		test.comment(`Staged hostapp extensions: ${services.join(', ')}`);

		gate.tgtVersion = await ext.osVersionId(this);

		// initDUT flashes the previous release and stages the hostapp
		await this.hup.initDUT(this, test, this.link);

		gate.seedVersion = await ext.osVersionId(this);

		// Helios cannot help a seed without the extension runtime
		const runtime = await ext.runtimeRegistered(this);
		if (runtime) {
			await seed.deliverHelios(this, test);
		}

		gate.heliosVersion = await ext.heliosVersion(this);
		gate.seedCapable = runtime && ext.atLeast(gate.heliosVersion, MIN_HELIOS);

		test.comment(
			`SEED is ${gate.seedVersion}, TGT is ${gate.tgtVersion}; ` +
				`SEED extension runtime: ${runtime ? 'yes' : 'no'}; ` +
				`SEED helios: ${gate.heliosVersion || 'none'}; ` +
				`SEED extension-capable: ${gate.seedCapable ? 'yes' : 'no'}`,
		);

		this.suite.context.set({ extensionsGate2: gate });
	},
	tests: [
		{
			title: 'The build extensions activate on the previous release',
			run: async function (test) {
				const gate = this.extensionsGate2;
				if (!ext.opened(test, skipReason(gate, RUNTIME))) {
					return;
				}

				test.is(
					(await ext.overlays(this)).length,
					0,
					'Should have no overlay container on the previous release',
				);

				const dutPaths = await ext.sendArtifacts(this, test);
				const images = {};

				for (const service of gate.services) {
					images[service] = await ext.loadImage(
						this,
						service,
						dutPaths[service],
					);
				}

				// The labels name TGT, so no os-version gate applies.
				// helios stages the overlays on the old OS.
				test.not(
					gate.seedVersion,
					'',
					'Should read the OS version of the previous release',
				);

				let activated = true;
				for (const service of gate.services) {
					const code = await ext.activateLocal(this, service, images[service]);
					test.is(
						code,
						'0',
						`Should activate the ${service} extension on the previous release`,
					);
					activated = activated && code === '0';
				}

				this.suite.context.set({
					extensionsGate2: { activated: activated, images: images },
				});

				await ext.captureKernelLog(this);
			},
		},
		{
			title: 'A rollback keeps the staged overlays on disk',
			run: async function (test) {
				const gate = this.extensionsGate2;
				if (!ext.opened(test, skipReason(gate, ACTIVE))) {
					return;
				}

				const before = await ext.inventory(this);
				const seedSlot = await ext.runningSlot(this);

				await ext.hupWithShortHealthWindow(this, test);

				test.is(
					await this.worker.executeCommandInHostOS(
						this.hup.BREAK_ENGINE,
						this.link,
					),
					'0',
					'Should replace balena-engine with a null link to trigger rollback-health',
				);

				await this.worker.rebootDut(this.link);

				// The first boot to answer is the broken target
				await ext.waitFor(
					this,
					test,
					async () => {
						return (await ext.runningSlot(this)) === seedSlot;
					},
					'Should have rolled back to the previous release slot',
				);
				await ext.waitFor(
					this,
					test,
					async () => {
						return (
							(await ext.exitCode(
								this,
								'test -f /mnt/state/rollback-health-breadcrumb',
							)) === '1'
						);
					},
					'Should have no rollback-health-breadcrumb in the state partition',
				);
				// The inventory needs the engine
				await ext.waitForUnit(
					this,
					test,
					'balena.service',
					'Should have balena.service active on the rolled-back boot',
				);
				await ext.captureKernelLog(this);

				await ext.markerIs(
					this,
					test,
					'rollback-health-triggered',
					'0',
					'Should have rollback-health-triggered in the state partition',
				);

				test.is(
					await ext.osVersionId(this),
					gate.seedVersion,
					'Should run the previous release again',
				);

				// A rollback never reaches the commit, so nothing sweeps
				test.is(
					await ext.journalCount(this, 0, STALE_PASS),
					0,
					'Should run no stale-OS pass on the rolled-back boot',
				);

				// The failed target's extensions must stay on disk.
				// Placement depends on the old mobynit, so record it.
				await ext.assertInventory(this, test, before, 'across the rollback');

				test.comment(
					`Placement on the rolled-back boot:\n${await ext.placement(this)}`,
				);
			},
		},
		{
			// rollback-altboot runs the recovery hooks of the previous release
			title: 'A fallback boot keeps the staged overlays on disk',
			run: async function (test) {
				const gate = this.extensionsGate2;
				if (!ext.opened(test, skipReason(gate, ACTIVE))) {
					return;
				}

				const before = await ext.inventory(this);
				const seedSlot = await ext.runningSlot(this);

				await this.hup.doHUP(this, test, 'local', this.link);

				test.is(
					await this.worker.executeCommandInHostOS(
						this.hup.BREAK_INIT,
						this.link,
					),
					'0',
					'Should delete mobynit to trigger rollback-altboot',
				);

				// The boot the DUT leaves for the broken slot
				const hupBoot = await ext.bootId(this);

				let back = true;
				try {
					await this.worker.rebootDut(this.link);
				} catch (error) {
					back = false;
					test.comment(
						`DUT did not return within the reboot window: ${error.message}`,
					);
				}

				if (!back) {
					test.comment('Power cycling the DUT once');
					await this.worker.off();
					await this.worker.on();
					try {
						await this.worker.executeCommandInHostOS('echo pass', this.link, {
							max_tries: 60,
							interval: 5000,
						}); // 5 min
					} catch (error) {
						test.fail(
							`DUT is unreachable after a fallback boot and one power cycle: ${error.message}`,
						);
						return;
					}
				}

				await ext.waitFor(
					this,
					test,
					async () => {
						return (await ext.runningSlot(this)) === seedSlot;
					},
					'Should have fallen back to the previous release slot',
				);
				// rollback-altboot recovers on the fallback boot, then reboots
				await ext.waitFor(
					this,
					test,
					async () => {
						return (
							(await ext.journalCount(this, -1, ALTBOOT_RECOVERY)) === 1 &&
							(await ext.journalCount(this, 0, ALTBOOT_RECOVERY)) === 0
						);
					},
					'Should have rebooted after rollback-altboot recovered the fallback boot',
				);
				await ext.captureKernelLog(this);

				// The broken slot never reached journald
				test.is(
					await ext.previousBootId(this, -2),
					hupBoot,
					'Should have no journal boot from the broken root partition',
				);

				test.is(
					await ext.osVersionId(this),
					gate.seedVersion,
					'Should run the previous release again',
				);

				// The recovery hooks clear both markers before altboot sets its own
				await ext.markerIs(
					this,
					test,
					'rollback-altboot-triggered',
					'0',
					'Should have rollback-altboot-triggered in the state partition',
				);

				await ext.markerIs(
					this,
					test,
					'rollback-health-triggered',
					'1',
					'Should not have rollback-health-triggered in the state partition',
				);

				// A fallback never reaches the commit, so nothing sweeps
				test.is(
					(await ext.journalCount(this, -1, STALE_PASS)) +
						(await ext.journalCount(this, 0, STALE_PASS)),
					0,
					'Should run no stale-OS pass on the fallback boot or the boot after it',
				);

				// The inventory needs the engine
				await ext.waitForUnit(
					this,
					test,
					'balena.service',
					'Should have balena.service active after the fallback boot',
				);

				// The old recovery hooks must keep what the target staged.
				// Placement depends on the old mobynit, so record it.
				await ext.assertInventory(this, test, before, 'across the fallback boot');

				test.comment(
					`Placement on the fallback boot:\n${await ext.placement(this)}`,
				);
			},
		},
		{
			title: 'The update carries the staged overlays into the new root',
			run: async function (test) {
				const gate = this.extensionsGate2;
				if (!ext.opened(test, skipReason(gate, ACTIVE))) {
					return;
				}

				// The rollback removed each override, so activate it again
				const running = await ext.cmdlineAbi(this);
				for (const service of gate.services) {
					const abi = ext.kernelAbiId(await ext.overlayLabels(this, service));
					if (abi === '' || abi === running) {
						continue;
					}
					await ext.withdrawLocal(this, service);
					test.is(
						await ext.activateLocal(this, service, gate.images[service]),
						'0',
						`Should activate the ${service} extension again after the rollback`,
					);
				}

				const before = await ext.inventory(this);

				await ext.hupWithShortHealthWindow(this, test);
				await this.worker.rebootDut(this.link);
				await ext.captureKernelLog(this);

				test.is(
					await ext.osVersionId(this),
					gate.tgtVersion,
					'Should run the build under test after the update',
				);

				await ext.waitForUnit(
					this,
					test,
					'rollback-health.service',
					'Should have rollback-health reach active',
				);

				await ext.markerIs(
					this,
					test,
					'rollback-health-triggered',
					'1',
					'Should not have rollback-health-triggered in the state partition',
				);

				await ext.waitForUnit(
					this,
					test,
					'hostapp-extensions-cleanup.service',
					'Should have hostapp-extensions-cleanup.service reach active after the update',
				);

				// The commit exits 0 when a hook fails.
				// Only the journal shows a clean commit.
				test.is(
					await ext.journalCount(this, 0, COMMIT_HOOKS_FAILED),
					0,
					'Should run the commit hooks without a failure',
				);

				// The overlays match the running OS.
				// The stale pass must keep them.
				await ext.assertInventory(this, test, before, 'across the commit');
				await ext.assertPlaced(this, test, gate, 'after the update');

				for (const service of gate.services) {
					await ext.probe(this, test, service);
				}
			},
		},
		{
			// Last, so the suite leaves the device as it was flashed
			title: 'Withdraw every local activation',
			run: async function (test) {
				const gate = this.extensionsGate2;
				const loaded = Object.keys(gate.images);
				if (loaded.length === 0) {
					test.plan(0, 'No extension image was loaded on the DUT');
					return;
				}

				for (const service of loaded) {
					await ext.withdrawLocal(this, service);
					await ext.removeImage(this, gate.images[service]);
				}

				test.is(
					(await ext.overlays(this)).length,
					0,
					'Should leave no overlay container on the DUT',
				);
			},
		},
	],
};
