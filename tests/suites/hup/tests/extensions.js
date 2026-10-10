/*
 * Copyright 2026 balena
 *
 * @license Apache-2.0
 */

'use strict';

const ext = require('../lib/extensions');

const ROLLBACK_MARKERS = [
	'rollback-health-breadcrumb',
	'rollback-health-triggered',
	'rollback-health-failed',
	'rollback-altboot-breadcrumb',
	'rollback-altboot-triggered',
];

// balena-extension-manager log lines, read as observations only
const STALE_PASS = 'removing stale extensions';
const TRIAL_OPENED = 'kernel override is on trial';
// Matches the per-hook warning and rollback-health's own; neither fails the unit
const COMMIT_HOOKS_FAILED = 'commit hook.* failed';

// The gate levels a child can require, in order
const RUNTIME = 0;
const STAGED = 1;
const ACTIVE = 2;

// Returns the reason this child must not run, or null
const skipReason = (gate, level) => {
	if (!gate.runtimeRegistered) {
		return 'The extension OCI runtime is not registered on the DUT';
	}
	if (level >= STAGED && gate.services.length === 0) {
		return 'No hostapp extension image staged for this build';
	}
	if (level >= ACTIVE && !gate.activated) {
		return 'The staged extensions were not activated on the DUT';
	}
	return null;
};

// True when the child may continue; a closed gate ends the node here
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

// A oneshot unit reads active only after its ExecStart returns
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
	// 0 means file exists, 1 means file does not exist
	test.is(
		await ext.exitCode(that, `test -f /mnt/state/${marker}`),
		wanted,
		message,
	);
};

const assertOverlaysIntact = async (that, test, gate, when, exited = false) => {
	const containers = await ext.overlays(that);

	for (const service of gate.services) {
		const name = ext.containerName(service);
		const container = containers.find((entry) => {
			return entry.name === name;
		});

		test.ok(
			container !== undefined,
			`Should still list the ${name} overlay container ${when}`,
		);

		if (exited) {
			test.ok(
				container !== undefined && container.status.startsWith('Exited (0)'),
				`Should have ${name} exited cleanly ${when}`,
			);
		}
	}

	const placed = await ext.placement(that);
	for (const service of gate.services) {
		// The service name is a substring of the container name mobynit logs
		test.ok(
			placed.includes(service),
			`Should still place the ${service} overlay in the root filesystem ${when}`,
		);
	}
};

const assertInventory = async (that, test, before, when) => {
	test.same(
		await ext.inventory(that),
		before,
		`Should keep every overlay container and image ${when}`,
	);
};

const assertNoRollbackMarker = async (that, test) => {
	for (const marker of ROLLBACK_MARKERS) {
		await markerIs(
			that,
			test,
			marker,
			'1',
			`Should not have ${marker} in the state partition`,
		);
	}
};

const assertBootUnits = async (that, test, gate, when) => {
	test.is(
		await ext.unitResult(that, 'hostapp-extensions-cleanup.service'),
		'success',
		`Should have hostapp-extensions-cleanup.service report success ${when}`,
	);

	if (gate.rollbackUnit) {
		test.is(
			await ext.unitResult(that, 'extension-rollback.service'),
			'success',
			`Should have extension-rollback.service report success ${when}`,
		);
	}
};

const assertOverrideKernel = async (that, test, gate, when) => {
	test.ok(
		gate.armed.includes(await ext.cmdlineAbi(that)),
		`Should run the override kernel ${when}`,
	);
};

const assertCommitted = async (that, test, when) => {
	const env = await ext.bootEnv(that);
	const slot = await ext.runningSlot(that);
	test.is(
		env[`kernel_override_abi_committed_${slot}`],
		env.kernel_override_abi,
		`Should commit the armed override for slot ${slot} ${when}`,
	);
};

// HUPs the build onto itself and leaves the inactive slot ready to break
const hupWithShortHealthWindow = async (that, test) => {
	await that.hup.doHUP(that, test, 'local', that.link);

	test.is(
		await that.worker.executeCommandInHostOS(
			that.hup.REDUCE_HEALTH_WINDOW,
			that.link,
		),
		'0', // only confirms the command ran, not that sed replaced anything
		'Should reduce rollback-health timeout to 3x10s',
	);
};

module.exports = {
	title: 'Hostapp extension tests',
	run: async function (test) {
		const services = Object.keys(ext.artifacts());

		const gate = {
			services: services,
			expected: process.env.EXTENSIONS_EXPECTED === 'true',
			runtimeRegistered: false,
			rollbackUnit: false,
			activated: false,
			kernelOverride: false,
			armed: [],
			images: {},
		};

		// The smoke node leaves the hostapp staged and the build under test
		// running; without it, flash so doHUP has a hostapp to install
		if (services.length > 0 && !this.hostappPath) {
			await this.hup.initDUT(this, test, this.link);
		}

		gate.runtimeRegistered = await ext.runtimeRegistered(this);
		gate.rollbackUnit = await ext.unitExists(this, 'extension-rollback.service');

		test.comment(
			`Staged hostapp extensions: ${services.length > 0 ? services.join(', ') : 'none'}`,
		);

		// Children read the gate through the suite context, not through this node
		this.suite.context.set({ extensionsGate: gate });
	},
	tests: [
		{
			title: 'Extension machinery is inert before any activation',
			run: async function (test) {
				const gate = this.extensionsGate;
				if (!opened(gate, test, RUNTIME)) {
					return;
				}

				test.is(
					(await ext.overlays(this)).length,
					0,
					'Should have no overlay container before any activation',
				);

				test.is(
					await ext.cmdlineAbi(this),
					'',
					'Should have no balena_kernel_abi on the kernel command line',
				);

				await assertBootUnits(this, test, gate, 'before any activation');

				test.is(
					await ext.rejectionRecord(this),
					'',
					'Should have an empty kernel override rejection record',
				);

				await ext.captureKernelLog(this);
			},
		},
		{
			title: 'Every extension activates and arms its kernel override',
			run: async function (test) {
				const gate = this.extensionsGate;
				// Fails here only, so the later children skip instead
				if (gate.services.length === 0 && gate.expected) {
					test.fail(
						'EXTENSIONS_EXPECTED is true but no extension image was staged for this build',
					);
					return;
				}
				// A staged artifact means the build ships the runtime
				if (gate.services.length > 0 && !gate.runtimeRegistered) {
					test.fail(
						'An extension image is staged but the extension OCI runtime is not registered',
					);
					return;
				}
				if (!opened(gate, test, STAGED)) {
					return;
				}

				const dutPaths = await ext.sendArtifacts(this, test);
				const images = {};
				const labels = {};

				for (const service of gate.services) {
					images[service] = await ext.loadImage(
						this,
						service,
						dutPaths[service],
					);
					labels[service] = await ext.imageLabels(this, images[service]);
				}
				this.suite.context.set({ extensionsGate: { images: images } });

				const versionId = await ext.osVersionId(this);
				// A label that does not cover VERSION_ID means the DUT does not run
				// the build these extensions were made for
				const osMatch = gate.services.every((service) => {
					return ext.osVersionMatches(labels[service], versionId);
				});
				if (!osMatch) {
					test.comment(
						`Staged extensions do not target ${versionId}; skipping activation`,
					);
					return;
				}

				let activated = true;
				for (const service of gate.services) {
					const code = await ext.activateLocal(this, service, images[service]);
					test.is(code, '0', `Should activate the ${service} extension`);
					activated = activated && code === '0';
				}

				const armed = gate.services
					.map((service) => {
						return ext.kernelAbiId(labels[service]);
					})
					.filter(Boolean);
				// An override claim is only testable where the validator ships
				const kernelOverride = armed.length > 0 && gate.rollbackUnit;

				this.suite.context.set({
					extensionsGate: {
						activated: activated,
						armed: armed,
						kernelOverride: kernelOverride,
					},
				});

				if (!activated || !kernelOverride) {
					return;
				}

				await this.worker.rebootDut(this.link);
				await ext.captureKernelLog(this);

				await assertOverrideKernel(this, test, { armed: armed }, 'after activation');

				// validate settles for 60s before it records a verdict
				await waitForUnit(
					this,
					test,
					'extension-rollback.service',
					'Should have extension-rollback reach active',
				);

				await assertCommitted(this, test, 'after activation');
			},
		},
		{
			title: 'Commit hook retains every overlay across a host OS update',
			run: async function (test) {
				const gate = this.extensionsGate;
				if (!opened(gate, test, ACTIVE)) {
					return;
				}

				const activePartition = await ext.activeSlot(this);
				const before = await ext.inventory(this);
				const rejected = await ext.rejectionRecord(this);

				await hupWithShortHealthWindow(this, test);

				await this.worker.rebootDut(this.link);

				await waitFor(
					this,
					test,
					async () => {
						const slot = await ext.activeSlot(this);
						return slot !== activePartition && slot !== '';
					},
					'Should have booted the updated root partition',
				);

				await waitForUnit(
					this,
					test,
					'rollback-health',
					'Should have rollback-health reach active',
				);
				await ext.captureKernelLog(this);

				await assertNoRollbackMarker(this, test);

				test.is(
					await ext.journalCount(this, 0, STALE_PASS),
					1,
					'Should run the stale-OS pass once at the commit',
				);

				test.is(
					await ext.journalCount(this, 0, COMMIT_HOOKS_FAILED),
					0,
					'Should run the commit hooks without a failure',
				);

				await assertInventory(this, test, before, 'across the commit');
				await assertOverlaysIntact(this, test, gate, 'after the update');

				if (gate.kernelOverride) {
					test.is(
						await ext.journalCount(this, 0, TRIAL_OPENED),
						0,
						'Should open no override trial on the update boot',
					);
					await assertOverrideKernel(this, test, gate, 'after the update');
					await assertCommitted(this, test, 'after the update');
				}

				test.is(
					await ext.rejectionRecord(this),
					rejected,
					'Should leave the kernel override rejection record unchanged',
				);

				// The overlays are only in the root filesystem after a boot
				for (const service of gate.services) {
					await ext.probe(this, test, service);
				}

				await this.worker.rebootDut(this.link);
				await ext.captureKernelLog(this);

				await assertBootUnits(this, test, gate, 'after a second boot');
				await assertInventory(this, test, before, 'after a second boot');
				await assertOverlaysIntact(this, test, gate, 'after a second boot');
			},
		},
		{
			title: 'Every overlay survives a rollback-health rollback',
			run: async function (test) {
				const gate = this.extensionsGate;
				if (!opened(gate, test, ACTIVE)) {
					return;
				}

				const activePartition = await ext.activeSlot(this);
				const before = await ext.inventory(this);
				const rejected = await ext.rejectionRecord(this);
				const audit = await ext.auditLine(this);

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

				await waitFor(
					this,
					test,
					async () => {
						return (await ext.activeSlot(this)) === activePartition;
					},
					'Should have rolled back to the original root partition',
				);
				await ext.captureKernelLog(this);

				await markerIs(
					this,
					test,
					'rollback-health-triggered',
					'0',
					'Should have rollback-health-triggered in the state partition',
				);

				await markerIs(
					this,
					test,
					'rollback-altboot-triggered',
					'1',
					'Should not have rollback-altboot-triggered in the state partition',
				);

				await markerIs(
					this,
					test,
					'rollback-health-failed',
					'1',
					'Should not have rollback-health-failed in the state partition',
				);

				// A rollback never reaches the commit, on either boot
				for (const boot of [-1, 0]) {
					test.is(
						await ext.journalCount(this, boot, STALE_PASS),
						0,
						`Should run no stale-OS pass on boot ${boot}`,
					);
				}

				await assertBootUnits(this, test, gate, 'after the rollback');
				await assertInventory(this, test, before, 'across the rollback');
				await assertOverlaysIntact(this, test, gate, 'after the rollback', true);

				if (gate.kernelOverride) {
					await assertOverrideKernel(this, test, gate, 'after the rollback');
					const line = await ext.auditLine(this);
					test.ok(
						line !== audit && line.includes('by=health'),
						'Should write a new override-health-triggered line',
					);
				}

				// A HUP rejection proves nothing about the kernel bytes
				test.is(
					await ext.rejectionRecord(this),
					rejected,
					'Should leave the kernel override rejection record unchanged',
				);
			},
		},
		{
			title: 'Every overlay survives a rollback-altboot fallback',
			run: async function (test) {
				const gate = this.extensionsGate;
				if (!opened(gate, test, ACTIVE)) {
					return;
				}

				const activePartition = await ext.activeSlot(this);
				const before = await ext.inventory(this);
				const rejected = await ext.rejectionRecord(this);
				const audit = await ext.auditLine(this);

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
					test.comment(`DUT did not return within the reboot window: ${error.message}`);
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

				await waitFor(
					this,
					test,
					async () => {
						return (await ext.activeSlot(this)) === activePartition;
					},
					'Should have fallen back to the original root partition',
				);
				await ext.captureKernelLog(this);

				// The broken slot never reached journald, so it left no boot
				test.is(
					await ext.previousBootId(this),
					hupBoot,
					'Should have no journal boot from the broken root partition',
				);

				await markerIs(
					this,
					test,
					'rollback-altboot-triggered',
					'0',
					'Should have rollback-altboot-triggered in the state partition',
				);

				await markerIs(
					this,
					test,
					'rollback-health-triggered',
					'1',
					'Should not have rollback-health-triggered in the state partition',
				);

				test.is(
					await ext.journalCount(this, 0, STALE_PASS),
					0,
					'Should run no stale-OS pass on the fallback boot',
				);

				await assertBootUnits(this, test, gate, 'after the fallback boot');
				await assertInventory(this, test, before, 'across the fallback boot');
				await assertOverlaysIntact(this, test, gate, 'after the fallback boot');

				if (gate.kernelOverride) {
					await assertOverrideKernel(this, test, gate, 'after the fallback boot');
				}

				// rollback-altboot runs no HUP reject, so neither record changes
				test.is(
					await ext.auditLine(this),
					audit,
					'Should leave override-health-triggered unchanged',
				);

				test.is(
					await ext.rejectionRecord(this),
					rejected,
					'Should leave the kernel override rejection record unchanged',
				);
			},
		},
		{
			// Last, so later files see the device as flashed
			title: 'Withdraw every local activation',
			run: async function (test) {
				const gate = this.extensionsGate;
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
