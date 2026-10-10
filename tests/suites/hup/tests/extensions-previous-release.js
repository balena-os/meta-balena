/*
 * Copyright 2026 balena
 *
 * @license Apache-2.0
 */

'use strict';

const ext = require('../lib/extensions');

// balena-extension-manager log lines, read as observations only
const STALE_PASS = 'removing stale extensions';
const COMMIT_HOOKS_FAILED = 'commit hook.* failed';

/*
 * These cases cross two builds. SEED is the older OS the device starts on, TGT
 * the build under test. Only the pre-extension SEED tier is implemented: SEED is
 * the production release the suite already fetches, so it carries the extension
 * runtime but no overlay of its own. The SEED-side, cross-ABI and
 * cross-OS-version assertions need a SEED that ships extensions and are not
 * here.
 */

const RUNTIME = 0;
const ACTIVE = 1;

const skipReason = (gate, level) => {
	if (gate.services.length === 0) {
		return 'No hostapp extension image staged for this build';
	}
	if (!gate.seedRuntime) {
		return 'The previous release does not register the extension OCI runtime';
	}
	if (level >= ACTIVE && !gate.activated) {
		return 'The extensions were not activated on the previous release';
	}
	return null;
};

const opened = (gate, test, level) => {
	const reason = skipReason(gate, level);
	if (reason !== null) {
		test.plan(0, reason);
		return false;
	}
	return true;
};

const waitFor = async (that, test, predicate, message) => {
	await test.resolves(
		that.utils.waitUntil(predicate, false, 5 * 60, 1000), // 5 min
		message,
	);
};

const waitForUnit = async (that, test, unit, message) => {
	await waitFor(
		that,
		test,
		async () => {
			return (
				(await that.worker.executeCommandInHostOS(
					`systemctl is-active ${unit} || true`,
					that.link,
				)) === 'active'
			);
		},
		message,
	);
};

const markerIs = async (that, test, marker, wanted, message) => {
	test.is(
		await ext.exitCode(that, `test -f /mnt/state/${marker}`),
		wanted,
		message,
	);
};

/*
 * Retention is one equality: the containers and images the activation created
 * must all still be there. This is the criterion that holds on both sides of
 * the HUP, unlike the placement, which depends on whether SEED's mobynit
 * composes overlays at all.
 */
const assertInventory = async (that, test, before, when) => {
	test.same(
		await ext.inventory(that),
		before,
		`Should keep every overlay container and image ${when}`,
	);
};

const assertPlaced = async (that, test, gate, when) => {
	const placed = await ext.placement(that);
	for (const service of gate.services) {
		test.ok(
			placed.includes(service),
			`Should place the ${service} overlay in the root filesystem ${when}`,
		);
	}
};

const hupWithShortHealthWindow = async (that, test) => {
	await that.hup.doHUP(that, test, 'local', that.link);

	test.is(
		await that.worker.executeCommandInHostOS(
			that.hup.REDUCE_HEALTH_WINDOW,
			that.link,
		),
		'0',
		'Should reduce rollback-health timeout to 3x10s',
	);
};

module.exports = {
	title: 'Hostapp extension tests from a previous release',
	run: async function (test) {
		const services = Object.keys(ext.artifacts());

		const gate = {
			services: services,
			expected: process.env.EXTENSIONS_EXPECTED === 'true',
			seedRuntime: false,
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

		// Back to the previous release. initDUT flashes the image the suite
		// fetched and re-stages the build's hostapp, so doHUP has its target.
		await this.hup.initDUT(this, test, this.link);

		gate.seedVersion = await ext.osVersionId(this);
		gate.seedRuntime = await ext.runtimeRegistered(this);

		test.comment(
			`SEED is ${gate.seedVersion}, TGT is ${gate.tgtVersion}; ` +
				`SEED extension runtime: ${gate.seedRuntime ? 'registered' : 'absent'}`,
		);

		this.suite.context.set({ extensionsGate2: gate });
	},
	tests: [
		{
			title: 'The build extensions activate on the previous release',
			run: async function (test) {
				const gate = this.extensionsGate2;

				if (gate.services.length === 0 && gate.expected) {
					test.fail(
						'EXTENSIONS_EXPECTED is true but no extension image was staged for this build',
					);
					return;
				}
				if (!opened(gate, test, RUNTIME)) {
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

				/*
				 * The os-version labels name TGT, not the running SEED. That
				 * mismatch is the point of these cases: helios stages the new
				 * release's overlays on the old OS before the reboot, so no
				 * os-version gate applies here.
				 */
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
				if (!opened(gate, test, ACTIVE)) {
					return;
				}

				const before = await ext.inventory(this);
				const seedSlot = await ext.runningSlot(this);

				await hupWithShortHealthWindow(this, test);

				test.is(
					await this.worker.executeCommandInHostOS(
						this.hup.BREAK_ENGINE,
						this.link,
					),
					'0',
					'Should replace balena-engine with a null link to trigger rollback-health',
				);

				await this.worker.rebootDut(this.link);
				await ext.captureKernelLog(this);

				test.is(
					await ext.runningSlot(this),
					seedSlot,
					'Should have rolled back to the previous release slot',
				);

				await markerIs(
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

				/*
				 * The criterion is that the failed target's extensions survive on
				 * disk. Whether this boot composes them depends on the previous
				 * release's mobynit, which holds no version axis, so the
				 * placement is recorded and not asserted.
				 */
				await assertInventory(this, test, before, 'across the rollback');

				test.comment(
					`Placement on the rolled-back boot:\n${await ext.placement(this)}`,
				);
			},
		},
		{
			title: 'The update carries the staged overlays into the new root',
			run: async function (test) {
				const gate = this.extensionsGate2;
				if (!opened(gate, test, ACTIVE)) {
					return;
				}

				const before = await ext.inventory(this);

				await hupWithShortHealthWindow(this, test);
				await this.worker.rebootDut(this.link);
				await ext.captureKernelLog(this);

				test.is(
					await ext.osVersionId(this),
					gate.tgtVersion,
					'Should run the build under test after the update',
				);

				await waitForUnit(
					this,
					test,
					'rollback-health.service',
					'Should have rollback-health reach active',
				);

				await markerIs(
					this,
					test,
					'rollback-health-triggered',
					'1',
					'Should not have rollback-health-triggered in the state partition',
				);

				test.is(
					await ext.unitResult(this, 'hostapp-extensions-cleanup.service'),
					'success',
					'Should have hostapp-extensions-cleanup.service report success after the update',
				);

				/*
				 * hostapp-update-hooks-v2 --commit exits 0 when a hook fails, so
				 * the journal is the only evidence that the commit ran clean.
				 */
				test.is(
					await ext.journalCount(this, 0, COMMIT_HOOKS_FAILED),
					0,
					'Should run the commit hooks without a failure',
				);

				/*
				 * The overlays now match the running OS, so the stale pass must
				 * keep them. With one build of each overlay there is nothing for
				 * it to discriminate; that is the deferred SEED tier.
				 */
				await assertInventory(this, test, before, 'across the commit');
				await assertPlaced(this, test, gate, 'after the update');

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
