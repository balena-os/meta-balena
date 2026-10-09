/*
 * Copyright 2026 balena
 *
 * @license Apache-2.0
 */

'use strict';

const ext = require('../../lib/extensions');

const MIN_HELIOS = [0, 28, 0];

/*
 * The overlay-only half of the cloud cases. The device is flashed with the build
 * under test and pinned to the draft of that same build, so the board revisions
 * match, helios sees a Running release and every profile change takes the
 * deploy_overlay then reboot_to_activate path. The cases that need an older OS
 * to update from, HE-PA-01 and HE-PA-02, are not here.
 */

const READY = 0;
const OVERLAYS = 1;
const OVERRIDE = 2;

const skipReason = (gate, level) => {
	if (!gate.ready) {
		return gate.reason;
	}
	if (level >= OVERLAYS && !gate.activated) {
		return 'The profiles were not activated on the release';
	}
	if (level >= OVERRIDE && !gate.kernelOverride) {
		return 'The release ships no kernel-override extension';
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

const atLeast = (version, floor) => {
	const parts = version.split('.').map((n) => {
		return parseInt(n, 10) || 0;
	});
	for (let i = 0; i < floor.length; i++) {
		if ((parts[i] || 0) > floor[i]) {
			return true;
		}
		if ((parts[i] || 0) < floor[i]) {
			return false;
		}
	}
	return true;
};

/*
 * helios defers every host task while rollback-health or extension-rollback
 * holds a pending start job, so a post-boot wait must cover them.
 */
const waitForHostUnits = async (that, gate) => {
	const units = ['rollback-health.service'];
	if (gate.rollbackUnit) {
		units.push('extension-rollback.service');
	}

	for (const unit of units) {
		await that.utils.waitUntil(
			async () => {
				const state = await ext.unitState(that, unit);
				return state === 'active' || state === 'failed' || state === '';
			},
			false,
			20 * 60,
			5000,
		);
	}
};

const waitForReboot = async (that, test, before, message) => {
	await test.resolves(
		that.utils.waitUntil(
			async () => {
				try {
					const now = await ext.bootId(that);
					return now !== '' && now !== before;
				} catch (e) {
					// The DUT is down or the link is not back yet
					return false;
				}
			},
			false,
			20 * 60,
			5000,
		),
		message,
	);
};

/**
 * One edit: write every row, read the target state until it shows the whole
 * change, then nudge once. A poll landing between two writes would split the
 * edit and the reboot count would show it.
 */
const settleTargetState = async (that, test, expected) => {
	await test.resolves(
		that.utils.waitUntil(
			async () => {
				const state = await ext.targetState(that);
				return JSON.stringify(state).length > 0 && expected(state);
			},
			false,
			10 * 60,
			5000,
		),
		'Should serve the edited target state before helios is nudged',
	);

	test.is(await ext.nudgeHelios(that), '202', 'Should accept the helios nudge');
};

/*
 * The shipped validate flags make a worst-case reject take about 16 minutes.
 * The waits are command-line flags, so the drop-in must clear and replace
 * ExecStart; an Environment= drop-in is inert here.
 */
const FAST_DROP_IN =
	'mkdir -p /run/systemd/system/extension-rollback.service.d && ' +
	"printf '%s\\n' '[Service]' 'ExecStart=' " +
	"'ExecStart=/usr/bin/balena-extension-manager validate --settle 5 --retry 5 --attempts 3' " +
	'> /run/systemd/system/extension-rollback.service.d/fast.conf && ' +
	'systemctl daemon-reload';

const LOCK_PATH = '/tmp/balena/updates.lock';

const takeUpdateLock = async (that) => {
	return that.cloud.executeCommandInContainer(
		`bash -c '(flock -x -n 200)200>${LOCK_PATH}'`,
		that.appServiceName,
		that.balena.uuid,
	);
};

const releaseUpdateLock = async (that) => {
	return that.cloud.executeCommandInContainer(
		`rm -f ${LOCK_PATH}`,
		that.appServiceName,
		that.balena.uuid,
	);
};

/*
 * The health check that judges the trial is rollback-tests, the same one
 * rollback-health runs. It fails when the VPN cannot connect and the pre-state
 * says it used to be up, so the lever is the pair the rollback tests already
 * use: stop the VPN, then force the pre-state. Masking the unit is the in-place
 * equivalent of their null link on the openvpn binary, which cannot be used
 * here because this trial does not change slot and the active rootfs is read
 * only.
 */
const BREAK_VPN =
	'systemctl mask --now openvpn.service ; ' +
	'rm -f /run/openvpn/vpn_status/active ; echo $?';

const RESTORE_VPN = 'systemctl unmask openvpn.service && systemctl start openvpn.service ; echo $?';

// Copied from the Broken VPN rollback test, so a failed openvpn is not ignored
const FORCE_VPN_PRESTATE =
	"sed 's/BALENAOS_ROLLBACK_VPNONLINE=0/BALENAOS_ROLLBACK_VPNONLINE=1/' " +
	'-i /mnt/state/rollback-health-variables && sync -f /mnt/state ; echo $?';

const lines = (text) => {
	return text
		.split('\n')
		.map((line) => {
			return line.trim();
		})
		.filter((line) => {
			return line !== '';
		});
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

module.exports = {
	title: 'Hostapp extension tests',
	run: async function (test) {
		const staged = ext.stagedConfig();

		const gate = {
			releaseId: staged.releaseId,
			supervisorReleaseId: staged.supervisorReleaseId,
			expected: staged.expected,
			ready: false,
			reason: 'No hostapp release id is staged for this run',
			release: null,
			profiles: [],
			services: [],
			activatorId: null,
			targetId: null,
			heliosVersion: '',
			rollbackUnit: false,
			kernelOverride: false,
			activated: false,
		};

		if (gate.releaseId === null) {
			test.comment(gate.reason);
			this.suite.context.set({ extensionsGate: gate });
			return;
		}

		gate.release = await ext.releaseInfo(this, gate.releaseId);
		if (gate.release === null) {
			gate.reason = `Release ${gate.releaseId} was not found`;
			this.suite.context.set({ extensionsGate: gate });
			return;
		}

		test.comment(
			`Release ${gate.releaseId} is ${gate.release.semver} on ` +
				`${gate.release.slug}, commit ${gate.release.commit}`,
		);

		/*
		 * Nothing in the API guards the hostApp a pin points at, so a wrong id
		 * would silently aim the device at a foreign hostApp.
		 */
		test.ok(gate.release.isHost, 'Should pin a release of a host application');
		test.is(
			gate.release.deviceType,
			this.suite.deviceType.slug,
			'Should pin a release built for this device type',
		);
		test.is(gate.release.status, 'success', 'Should pin a successful release');
		test.is(
			gate.release.isInvalidated,
			false,
			'Should pin a release that is not invalidated',
		);

		gate.profiles = await ext.discoverProfiles(this, gate.releaseId);
		gate.services = gate.profiles.slice();
		test.comment(
			`Profiles on the release: ${gate.profiles.length > 0 ? gate.profiles.join(', ') : 'none'}`,
		);

		if (gate.profiles.length === 0) {
			if (gate.expected) {
				test.fail(
					'EXTENSIONS_EXPECTED is true but the release carries no image_profile row',
				);
			}
			gate.reason = 'The release carries no profile to activate';
			this.suite.context.set({ extensionsGate: gate });
			return;
		}

		if (gate.supervisorReleaseId !== null) {
			await ext.pinSupervisor(this, gate.supervisorReleaseId);
			await test.resolves(
				this.utils.waitUntil(
					async () => {
						return (await ext.supervisorContainers(this)).some((line) => {
							return line.startsWith('core-next');
						});
					},
					false,
					20 * 60,
					5000,
				),
				'Should run core-next after the supervisor pin',
			);
		}

		gate.heliosVersion = await ext.heliosVersion(this);
		test.comment(`helios version: ${gate.heliosVersion || 'unknown'}`);
		if (!atLeast(gate.heliosVersion, MIN_HELIOS)) {
			gate.reason = `helios ${gate.heliosVersion || 'unknown'} is older than 0.28.0`;
			this.suite.context.set({ extensionsGate: gate });
			return;
		}

		gate.rollbackUnit = await ext.unitExists(this, 'extension-rollback.service');
		gate.activatorId = await ext.applicationId(this, this.balena.application);
		gate.targetId = gate.release.applicationId;

		// Pinning with nothing activated leaves the device as it is: no overlay
		await ext.pinRelease(this, gate.releaseId);

		gate.ready = true;
		gate.reason = null;
		this.suite.context.set({ extensionsGate: gate });

		this.suite.teardown.register(async () => {
			// A leaked row changes what a later run is served
			try {
				await ext.deactivateProfiles(
					this,
					gate.profiles,
					gate.activatorId,
					gate.targetId,
				);
			} catch (e) {
				this.log(`Error while removing profile activations: ${e.message}`);
			}
		});
	},
	tests: [
		{
			title: 'Extension machinery is inert before any activation',
			run: async function (test) {
				const gate = this.extensionsGate;
				if (!opened(gate, test, READY)) {
					return;
				}

				test.ok(
					await ext.runtimeRegistered(this),
					'Should register the extension OCI runtime on the device',
				);

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

				test.is(
					await ext.rejectionRecord(this),
					'',
					'Should have an empty kernel override rejection record',
				);

				test.same(
					await ext.listActivations(this, gate.activatorId, gate.targetId),
					[],
					'Should start with no profile activated',
				);

				// Spec question 1: record the pair, do not assert it
				test.comment(`Board revision on the device: ${await ext.boardRev(this)}`);

				await ext.captureKernelLog(this);
			},
		},
		{
			title: 'An activation on the running release needs one reboot and no install',
			run: async function (test) {
				const gate = this.extensionsGate;
				if (!opened(gate, test, READY)) {
					return;
				}

				const boots = await ext.bootCount(this);
				const boot = await ext.bootId(this);

				await ext.activateProfiles(
					this,
					gate.profiles,
					gate.activatorId,
					gate.targetId,
				);

				await settleTargetState(this, test, (state) => {
					return JSON.stringify(state).includes(gate.release.commit);
				});

				await waitForReboot(
					this,
					test,
					boot,
					'Should reboot to activate the overlays',
				);
				await waitForHostUnits(this, gate);
				await ext.captureKernelLog(this);

				test.is(
					(await ext.bootCount(this)) - boots,
					1,
					'Should take exactly one reboot to activate',
				);

				/*
				 * The overlay-only path adds no install, so the host OS updater
				 * never runs. Result defaults to success on a unit that never
				 * ran, so the monotonic activation stamp is the real evidence:
				 * it is 0 when the unit has not entered active this boot.
				 */
				test.is(
					await ext.unitActiveEnter(this, 'os-update.service'),
					'0',
					'Should run no host OS update to activate an overlay',
				);

				const containers = await ext.overlays(this);
				test.is(
					containers.length,
					gate.profiles.length,
					'Should create one activation container per profile',
				);

				for (const container of containers) {
					const shape = await ext.containerShape(this, container.name);
					test.is(
						shape.runtime,
						'extension',
						`Should run ${container.name} under the extension runtime`,
					);
					test.is(
						shape.network,
						'none',
						`Should give ${container.name} no network`,
					);
					test.is(
						shape.exitCode,
						'0',
						`Should have ${container.name} exit 0`,
					);
				}

				await assertPlaced(this, test, gate, 'after the activation');

				for (const service of gate.services) {
					await ext.probe(this, test, service);
				}

				this.suite.context.set({ extensionsGate: { activated: true } });
			},
		},
		{
			title: 'An armed kernel override is committed after a healthy boot',
			run: async function (test) {
				const gate = this.extensionsGate;
				if (!opened(gate, test, OVERLAYS)) {
					return;
				}

				const abi = await ext.cmdlineAbi(this);
				if (abi === '') {
					test.plan(0, 'The release ships no kernel-override extension');
					return;
				}

				this.suite.context.set({ extensionsGate: { kernelOverride: true } });

				/*
				 * Armed outside a host OS update, so extension-rollback puts it on
				 * trial. The commit follows the health verdict, not the arm.
				 */
				const env = await ext.bootEnv(this);
				const slot = await ext.runningSlot(this);
				test.is(
					env[`kernel_override_abi_committed_${slot}`],
					env.kernel_override_abi,
					`Should commit the armed override for slot ${slot}`,
				);

				test.is(
					await ext.rejectionRecord(this),
					'',
					'Should leave the kernel override rejection record empty',
				);
			},
		},
		{
			title: 'Withdrawing every profile returns the device to the plain OS',
			run: async function (test) {
				const gate = this.extensionsGate;
				if (!opened(gate, test, OVERLAYS)) {
					return;
				}

				const boots = await ext.bootCount(this);
				const boot = await ext.bootId(this);
				const record = await ext.rejectionRecord(this);

				await ext.deactivateProfiles(
					this,
					gate.profiles,
					gate.activatorId,
					gate.targetId,
				);

				await settleTargetState(this, test, (state) => {
					return gate.services.every((service) => {
						return !JSON.stringify(state).includes(`"${service}"`);
					});
				});

				await waitForReboot(
					this,
					test,
					boot,
					'Should reboot to apply the withdrawal',
				);
				await waitForHostUnits(this, gate);
				await ext.captureKernelLog(this);

				test.is(
					(await ext.bootCount(this)) - boots,
					1,
					'Should take exactly one reboot to withdraw',
				);

				test.is(
					(await ext.overlays(this)).length,
					0,
					'Should leave no overlay container after the withdrawal',
				);

				const placed = await ext.placement(this);
				for (const service of gate.services) {
					test.ok(
						!placed.includes(service),
						`Should not place the ${service} overlay after the withdrawal`,
					);
				}

				if (gate.kernelOverride) {
					test.is(
						await ext.cmdlineAbi(this),
						'',
						'Should run the base kernel after the withdrawal',
					);

					const env = await ext.bootEnv(this);
					test.is(
						env.kernel_override_abi || '',
						'',
						'Should clear the armed override after the withdrawal',
					);
				}

				// A withdrawal rejects nothing
				test.is(
					await ext.rejectionRecord(this),
					record,
					'Should leave the kernel override rejection record unchanged',
				);
			},
		},
		{
			/*
			 * Last. A rejected ABI stays in the record and nothing on the device
			 * retires it, so the suite's device must not be reused after this.
			 */
			title: 'A failed trial returns the device to the stock kernel and refuses the override',
			run: async function (test) {
				const gate = this.extensionsGate;
				if (!opened(gate, test, OVERRIDE)) {
					return;
				}

				const before = lines(await ext.rejectionRecord(this));

				test.is(
					await ext.exitCode(this, FAST_DROP_IN),
					'0',
					'Should install the fast validate drop-in',
				);

				/*
				 * The lock holds helios at the reboot so the test owns it, the
				 * way the rollback tests own theirs. Without it helios reboots
				 * as soon as the overlay is deployed and the trial is judged
				 * before the sabotage lands.
				 */
				await takeUpdateLock(this);

				await ext.activateProfiles(
					this,
					gate.profiles,
					gate.activatorId,
					gate.targetId,
				);
				test.is(
					await ext.nudgeHelios(this),
					'202',
					'Should accept the helios nudge',
				);

				let armed = '';
				await test.resolves(
					this.utils.waitUntil(
						async () => {
							const env = await ext.bootEnv(this);
							armed = env.kernel_override_abi || '';
							return armed !== '';
						},
						false,
						20 * 60,
						5000,
					),
					'Should arm the kernel override while the reboot is locked',
				);
				test.comment(`Armed ABI: ${armed}`);

				test.is(
					await ext.host(this, BREAK_VPN),
					'0',
					'Should stop the VPN before the judged boot',
				);

				test.is(
					await ext.host(this, FORCE_VPN_PRESTATE),
					'0', // confirms the command ran, not that sed replaced anything
					'Should force the pre-state so a failed VPN is not ignored',
				);

				const boots = await ext.bootCount(this);
				const boot = await ext.bootId(this);

				/*
				 * Reboot from the test, as the rollback tests do, rather than
				 * releasing the lock and waiting for helios. The override is
				 * already armed, so this boot is the judged one, and the lock
				 * stays held so helios cannot reboot underneath it. Everything
				 * from here reaches the DUT over the worker's link.
				 */
				await this.worker.rebootDut(this.link);
				await waitForReboot(this, test, boot, 'Should reach the judged boot');

				/*
				 * The judged boot fails its health check and the device undoes
				 * the override by itself. Do not touch it until it is back.
				 */
				await test.resolves(
					this.utils.waitUntil(
						async () => {
							return (await ext.cmdlineAbi(this)) === '';
						},
						false,
						30 * 60,
						5000,
					),
					'Should return on the stock kernel by itself',
				);
				await waitForHostUnits(this, gate);
				await ext.captureKernelLog(this);

				test.is(
					(await ext.bootCount(this)) - boots,
					2,
					'Should take one reboot after the judged boot',
				);

				test.is(
					await ext.exitCode(this, 'balena-engine info'),
					'0',
					'Should leave the engine healthy',
				);

				// Nothing armed in either slot
				const env = await ext.bootEnv(this);
				test.is(
					env.kernel_override_abi || '',
					'',
					'Should leave no armed override',
				);
				for (const slot of ['A', 'B']) {
					test.not(
						env[`kernel_override_abi_committed_${slot}`],
						armed,
						`Should withdraw the committed override of slot ${slot}`,
					);
				}

				/*
				 * Assert the bootenv and the record, not the boot-by-abi
				 * directory, which a redeploy re-publishes.
				 */
				const after = lines(await ext.rejectionRecord(this));
				test.same(
					after.slice(0, before.length),
					before,
					'Should keep the existing rejection record',
				);
				test.is(
					after.length - before.length,
					1,
					'Should add exactly one line to the rejection record',
				);
				test.is(
					after[after.length - 1],
					armed,
					'Should record the rejected ABI as a bare line',
				);

				test.is(
					await ext.host(this, RESTORE_VPN),
					'0',
					'Should restore the VPN',
				);
				await releaseUpdateLock(this);

				const settled = await ext.bootCount(this);
				test.is(
					await ext.nudgeHelios(this),
					'202',
					'Should accept the helios nudge',
				);
				await this.utils.waitUntil(
					async () => {
						return (await ext.unitState(this, 'openvpn.service')) === 'active';
					},
					false,
					10 * 60,
					5000,
				);

				// A rejected override cannot put the device in a reboot loop
				test.is(
					await ext.bootCount(this),
					settled,
					'Should not reboot again after the rejection',
				);
			},
		},
	],
};
