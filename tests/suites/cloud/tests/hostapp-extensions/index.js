/*
 * Copyright 2026 balena
 *
 * @license Apache-2.0
 */

'use strict';

const ext = require('../../lib/extensions');

// The device runs the build that the release pins.
// HE-PA-01 and HE-PA-02 need an older OS.

// The first helios with hostapp extension support
const MIN_HELIOS = [0, 28, 0];

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

// helios defers host tasks while these units are pending
const waitForHostUnits = async (that, gate) => {
	const units = ['rollback-health.service'];
	if (gate.rollbackUnit) {
		units.push('extension-rollback.service');
	}

	for (const unit of units) {
		await that.utils.waitUntil(
			async () => {
				const state = await ext.unitState(that, unit);
				if (state === 'active' || state === 'failed' || state === '') {
					return true;
				}
				// rollback-health runs only after a host OS update.
				// An unstarted unit also reads no, so require a timestamp.
				const [result, stamp] = (
					await ext.host(
						that,
						`systemctl show -p ConditionResult,ConditionTimestampMonotonic --value ${unit} || true`,
					)
				).split('\n');
				return result === 'no' && stamp !== undefined && stamp !== '0';
			},
			false,
			240, // 20 min
			5000,
		);
	}
};

// Any boot id other than previousBootId means a reboot
const waitForReboot = async (that, test, previousBootId, message) => {
	await test.resolves(
		that.utils.waitUntil(
			async () => {
				try {
					const currentBootId = await ext.bootId(that);
					return currentBootId !== '' && currentBootId !== previousBootId;
				} catch (e) {
					// The DUT is down or the link is not back yet
					return false;
				}
			},
			false,
			240, // 20 min
			5000,
		),
		message,
	);
};

// Nudge once after the API serves the whole edit.
// A split edit shows as an extra reboot.
const settleTargetState = async (that, test, expected) => {
	await test.resolves(
		that.utils.waitUntil(
			async () => {
				return expected(await ext.targetState(that));
			},
			false,
			120, // 10 min
			5000,
		),
		'Should serve the edited target state before helios is nudged',
	);

	test.is(await ext.nudgeHelios(that), '202', 'Should accept the helios nudge');
};

// The shipped flags take up to 16 minutes to reject.
// Edit the slot: a /run drop-in is lost at reboot.
const VALIDATE_UNIT =
	'$(find /mnt/sysroot/active/ -path "*/usr/lib/systemd/system/extension-rollback.service" | head -1)';
const VALIDATE_EXEC = 'ExecStart=/usr/bin/balena-extension-manager validate';
const FAST_VALIDATE =
	`f=${VALIDATE_UNIT} && [ -n "$f" ] && cp -p "$f" "$f.leviathan" && ` +
	`sed -i 's|^${VALIDATE_EXEC}.*|${VALIDATE_EXEC} --settle 20 --retry 5 --attempts 3|' "$f" && ` +
	'sync -f "$f"';
const RESTORE_VALIDATE =
	`f=${VALIDATE_UNIT} ; [ -f "$f.leviathan" ] && mv "$f.leviathan" "$f" && sync -f "$f" ; true`;

// mobynit reads it in the claim and at the pivot
const NO_OVERLAYS = 'mobynit.no_overlays';

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

// rollback-tests fails when the VPN was up before.
// Breaking the binary before the reboot removes the race.
const VPN_BINARY =
	'$(find /mnt/sysroot/active/ -path "*/usr/sbin/openvpn" | head -1)';
// A regular file, not a link: the restore mounts over it
const BREAK_VPN_BINARY =
	`f=${VPN_BINARY} && [ -n "$f" ] && mv "$f" "$f.leviathan" && ` +
	': > "$f" && sync -f "$f.leviathan"';

// The live root caches the broken lower entry.
// The bind mount lasts until the next boot.
const RESTORE_VPN =
	`f=${VPN_BINARY} ; if [ -e "$f.leviathan" ] ; then ` +
	'mv -f "$f.leviathan" "$f" && sync -f "$f" && ' +
	'mount --bind "$f" /usr/sbin/openvpn ; ' +
	'fi ; systemctl restart openvpn.service ; echo $?';

// The override trial reads its baseline from this file
const FORCE_VPN_PRESTATE =
	"sed 's/BALENAOS_ROLLBACK_VPNONLINE=0/BALENAOS_ROLLBACK_VPNONLINE=1/' " +
	'-i /mnt/state/extension-health-variables && sync -f /mnt/state ; echo $?';

module.exports = {
	title: 'Hostapp extension tests',
	run: async function (test) {
		const staged = ext.stagedConfig();

		const gate = {
			releaseId: staged.releaseId,
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

		// ssh-auth leaves no key. These cases need local SSH.
		await this.writeConfigJsonProp(
			test,
			'os.sshKeys',
			[this.context.get().sshKey.pubKey.trim()],
			this.balena.uuid,
		);
		await test.resolves(
			this.utils.waitUntil(
				async () => {
					return (
						(await this.worker.executeCommandInHostOS('echo -n pass', this.link)) ===
						'pass'
					);
				},
				false,
				10,
				5 * 1000,
			),
			'Should reach the device over local SSH with the suite key',
		);

		gate.release = await ext.releaseInfo(this, gate.releaseId);
		if (gate.release === null) {
			gate.reason =
				`Release ${gate.releaseId} was not found: check the API ` +
				'environment and the read access of the test key';
			test.fail(gate.reason);
			this.suite.context.set({ extensionsGate: gate });
			return;
		}

		test.comment(
			`Release ${gate.releaseId} is ${gate.release.semver} on ` +
				`${gate.release.slug}, commit ${gate.release.commit}`,
		);

		// The API accepts a pin to a foreign hostApp
		const checks = [
			[gate.release.isHost === true, 'Should pin a release of a host application'],
			[
				gate.release.deviceType === this.suite.deviceType.slug,
				'Should pin a release built for this device type',
			],
			[gate.release.status === 'success', 'Should pin a successful release'],
			[
				gate.release.isInvalidated === false,
				'Should pin a release that is not invalidated',
			],
		];
		for (const [passed, message] of checks) {
			test.ok(passed, message);
		}
		const usable = checks.every(([passed]) => {
			return passed;
		});
		if (!usable) {
			gate.reason =
				`Release ${gate.releaseId} is not usable: ` +
				`${gate.release.deviceType}, ${gate.release.status}`;
			this.suite.context.set({ extensionsGate: gate });
			return;
		}

		gate.profiles = await ext.discoverProfiles(this, gate.releaseId);
		gate.services = gate.profiles.slice();
		test.comment(
			`Profiles on the release: ${gate.profiles.length > 0 ? gate.profiles.join(', ') : 'none'}`,
		);

		if (gate.profiles.length === 0) {
			if (gate.release.shipsExtensions) {
				test.fail(
					'The release composition ships extensions but carries no image_profile row',
				);
			}
			gate.reason = 'The release carries no profile to activate';
			this.suite.context.set({ extensionsGate: gate });
			return;
		}

		const supervisorReleaseId = ext.stagedConfig().supervisorReleaseId;
		if (supervisorReleaseId !== null) {
			await ext.pinSupervisor(this, supervisorReleaseId);
			// The timer applies a pin up to 75 minutes after boot
			await ext.host(this, 'systemctl start update-balena-supervisor');
			await test.resolves(
				this.utils.waitUntil(
					async () => {
						return (
							(await ext.host(
								this,
								'systemctl is-active update-balena-supervisor || true',
							)) !== 'active'
						);
					},
					false,
					240, // 20 min
					5000,
				),
				'Should finish the supervisor update',
			);
			// The old core-next can answer until the new one starts
			await test.resolves(
				this.utils.waitUntil(
					async () => {
						return ext.atLeast(await ext.heliosVersion(this), MIN_HELIOS);
					},
					false,
					240, // 20 min
					5000,
				),
				'Should run the helios of the pinned supervisor',
			);
		}

		// The supervisor starts core-next after it starts itself
		await test.resolves(
			this.utils.waitUntil(
				async () => {
					gate.heliosVersion = await ext.heliosVersion(this);
					return gate.heliosVersion !== '';
				},
				false,
				60, // 5 min
				5000,
			),
			'Should run helios from the supervisor of the release',
		);
		// The activation case fails when helios has no extension support
		test.comment(`helios version: ${gate.heliosVersion || 'none'}`);

		gate.rollbackUnit = await ext.unitExists(this, 'extension-rollback.service');
		gate.activatorId = await ext.applicationId(this, this.balena.application);
		gate.targetId = gate.release.applicationId;

		// A pin with no profile activated changes nothing
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
				if (!ext.opened(test, skipReason(gate, READY))) {
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
				if (!ext.opened(test, skipReason(gate, READY))) {
					return;
				}

				const boots = await ext.bootCount(this);
				const boot = await ext.bootId(this);
				const slot = await ext.runningSlot(this);

				await ext.activateProfiles(
					this,
					gate.profiles,
					gate.activatorId,
					gate.targetId,
				);

				await settleTargetState(this, test, (state) => {
					return gate.services.every((service) => {
						return JSON.stringify(state).includes(`"${service}"`);
					});
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

				// A host OS update boots the other slot
				test.is(
					await ext.runningSlot(this),
					slot,
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

				await ext.assertPlaced(this, test, gate, 'after the activation');

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
				if (!ext.opened(test, skipReason(gate, OVERLAYS))) {
					return;
				}

				// The label marks an override, not the cmdline
				const shipped = [];
				for (const service of gate.services) {
					const abi = ext.kernelAbiId(await ext.overlayLabels(this, service));
					if (abi !== '') {
						shipped.push(abi);
					}
				}
				if (shipped.length === 0) {
					test.plan(0, 'The release ships no kernel-override extension');
					return;
				}

				const running = shipped.includes(await ext.cmdlineAbi(this));
				test.ok(running, 'Should run the override kernel that the release ships');
				// The later override cases skip on this failure
				if (!running) {
					return;
				}

				this.suite.context.set({ extensionsGate: { kernelOverride: true } });

				// extension-rollback puts this override on trial.
				// The commit follows the health verdict.
				const env = await ext.bootEnv(this);
				const slot = await ext.runningSlot(this);
				test.ok(env.kernel_override_abi, 'Should keep the override armed');
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
			title: 'mobynit.no_overlays boots the plain OS and keeps the arm',
			run: async function (test) {
				const gate = this.extensionsGate;
				if (!ext.opened(test, skipReason(gate, OVERLAYS))) {
					return;
				}

				// A secure boot image signs its command line
				if (['1', 'true'].includes(process.env.FLASHER_SECUREBOOT)) {
					test.plan(0, 'The command line is signed on a secure boot image');
					return;
				}
				const cmdline = await ext.cmdlineHook(this);
				if (cmdline === null) {
					test.plan(0, 'No hook sets the kernel command line on this device');
					return;
				}

				const slot = await ext.runningSlot(this);
				const armedEnv = await ext.bootEnv(this);
				const armed = armedEnv.kernel_override_abi || '';
				const committed = armedEnv[`kernel_override_abi_committed_${slot}`] || '';
				const record = await ext.rejectionRecord(this);

				this.suite.teardown.register(() => {
					return cmdline.restore();
				});
				test.is(
					await cmdline.add(NO_OVERLAYS),
					'0',
					`Should add ${NO_OVERLAYS} to ${cmdline.path}`,
				);

				let boots = await ext.bootCount(this);
				let boot = await ext.bootId(this);
				await this.worker.rebootDut(this.link);
				await waitForReboot(
					this,
					test,
					boot,
					'Should reboot with the overlays disabled',
				);
				await waitForHostUnits(this, gate);
				await ext.captureKernelLog(this);

				test.is(
					(await ext.bootCount(this)) - boots,
					1,
					'Should take exactly one reboot to disable the overlays',
				);

				// Without the flag every assertion below passes for nothing
				test.ok(
					await ext.cmdlineHas(this, NO_OVERLAYS),
					`Should boot with ${NO_OVERLAYS} on the command line`,
				);

				const placed = await ext.placement(this);
				for (const service of gate.services) {
					test.ok(
						!placed.includes(service),
						`Should not place the ${service} overlay with the overlays disabled`,
					);
				}

				if (gate.kernelOverride) {
					test.is(
						await ext.cmdlineAbi(this),
						'',
						'Should boot the stock kernel while nothing is mounted',
					);
				}

				// Disabling the overlays is not a failed trial
				const env = await ext.bootEnv(this);
				test.is(
					env.kernel_override_abi || '',
					armed,
					'Should keep the armed override',
				);
				test.is(
					env[`kernel_override_abi_committed_${slot}`] || '',
					committed,
					`Should keep the committed override of slot ${slot}`,
				);
				test.is(
					await ext.rejectionRecord(this),
					record,
					'Should leave the kernel override rejection record unchanged',
				);

				test.is(
					await cmdline.restore(),
					'0',
					`Should restore ${cmdline.path}`,
				);

				boots = await ext.bootCount(this);
				boot = await ext.bootId(this);
				await this.worker.rebootDut(this.link);
				await waitForReboot(
					this,
					test,
					boot,
					'Should reboot with the overlays enabled again',
				);
				await waitForHostUnits(this, gate);
				await ext.captureKernelLog(this);

				test.is(
					(await ext.bootCount(this)) - boots,
					1,
					'Should take exactly one reboot to enable the overlays again',
				);
				test.ok(
					!(await ext.cmdlineHas(this, NO_OVERLAYS)),
					`Should boot without ${NO_OVERLAYS} on the command line`,
				);

				await ext.assertPlaced(this, test, gate, 'after the overlays are enabled again');

				if (gate.kernelOverride) {
					test.is(
						await ext.cmdlineAbi(this),
						armed,
						'Should boot the override kernel again',
					);
				}
			},
		},
		{
			title: 'Withdrawing every profile returns the device to the plain OS',
			run: async function (test) {
				const gate = this.extensionsGate;
				if (!ext.opened(test, skipReason(gate, OVERLAYS))) {
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
			// Last: nothing retires a rejected ABI from the record.
			// Do not use the device again after this case.
			title: 'A failed trial returns the device to the stock kernel and refuses the override',
			run: async function (test) {
				const gate = this.extensionsGate;
				if (!ext.opened(test, skipReason(gate, OVERRIDE))) {
					return;
				}

				const before = ext.lines(await ext.rejectionRecord(this));

				this.suite.teardown.register(() => {
					return ext.host(this, RESTORE_VALIDATE);
				});
				test.is(
					await ext.exitCode(this, FAST_VALIDATE),
					'0',
					'Should shorten the validation in the active slot',
				);

				// The lock lets the test own the reboot.
				// Without it helios reboots before the sabotage.
				await takeUpdateLock(this);

				await ext.activateProfiles(
					this,
					gate.profiles,
					gate.activatorId,
					gate.targetId,
				);
				await settleTargetState(this, test, (state) => {
					return gate.services.every((service) => {
						return JSON.stringify(state).includes(`"${service}"`);
					});
				});

				let armed = '';
				await test.resolves(
					this.utils.waitUntil(
						async () => {
							const env = await ext.bootEnv(this);
							armed = env.kernel_override_abi || '';
							return armed !== '';
						},
						false,
						240, // 20 min
						5000,
					),
					'Should arm the kernel override while the reboot is locked',
				);
				test.comment(`Armed ABI: ${armed}`);

				test.is(
					await ext.host(this, FORCE_VPN_PRESTATE),
					'0', // confirms the command ran, not that sed replaced anything
					'Should force the pre-state so a failed VPN is not ignored',
				);

				this.suite.teardown.register(() => {
					return ext.host(this, RESTORE_VPN);
				});
				test.is(
					await ext.exitCode(this, BREAK_VPN_BINARY),
					'0',
					'Should break openvpn in the active slot',
				);

				const boots = await ext.bootCount(this);
				const boot = await ext.bootId(this);

				// The override is armed, so this boot is judged.
				// The lock stops a helios reboot during the trial.
				await this.worker.rebootDut(this.link);
				await waitForReboot(this, test, boot, 'Should reach the judged boot');

				// The device undoes the override without help.
				// Do not touch it until it is back.
				await test.resolves(
					this.utils.waitUntil(
						async () => {
							return (await ext.cmdlineAbi(this)) === '';
						},
						false,
						360, // 30 min
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

				// A redeploy restores boot-by-abi, so assert the record
				const after = ext.lines(await ext.rejectionRecord(this));
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
					'Should restart openvpn',
				);
				// The lock release goes through the VPN
				await test.resolves(
					this.utils.waitUntil(
						async () => {
							return (
								(await ext.unitState(this, 'openvpn.service')) === 'active'
							);
						},
						false,
						120, // 10 min
						5000,
					),
					'Should restore the VPN',
				);
				await ext.host(this, RESTORE_VALIDATE);
				await releaseUpdateLock(this);

				const settled = await ext.bootId(this);
				test.is(
					await ext.nudgeHelios(this),
					'202',
					'Should accept the helios nudge',
				);

				// A rejected override must not cause a reboot loop.
				// Watch while helios applies the target state.
				let rearmed = false;
				await this.utils
					.waitUntil(
						async () => {
							rearmed = !!(await ext.bootEnv(this)).kernel_override_abi;
							return rearmed || (await ext.bootId(this)) !== settled;
						},
						false,
						120, // 10 min
						5000,
					)
					.catch(() => {
						// A timeout means nothing changed
					});
				test.notOk(rearmed, 'Should not arm the override again after the rejection');

				// A reboot in progress at the end returns a new boot id
				let current = '';
				await this.utils.waitUntil(
					async () => {
						current = await ext.bootId(this);
						return current !== '';
					},
					false,
					240, // 20 min
					5000,
				);
				test.is(current, settled, 'Should not reboot again after the rejection');
			},
		},
	],
};
