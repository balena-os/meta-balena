/*
 * Copyright 2026 balena
 *
 * @license Apache-2.0
 */

'use strict';

const request = require('request-promise');
const { existsSync, readFileSync } = require('fs');
const { join } = require('path');

/*
 * A workflow env var cannot reach a test: the core receives only
 * FLASHER_SECUREBOOT, and it builds the suite options from a fixed list of
 * config keys. CI therefore writes this file into the suite directory, which is
 * uploaded whole, the same route the hup extension archives take. process.env
 * is the fallback for manual runs.
 */
const STAGED_CONFIG = join(__dirname, '..', 'hostapp.json');

const stagedConfig = () => {
	let staged = {};
	if (existsSync(STAGED_CONFIG)) {
		try {
			staged = JSON.parse(readFileSync(STAGED_CONFIG, 'utf8'));
		} catch (e) {
			staged = {};
		}
	}

	return {
		releaseId:
			parseInt(staged.releaseId, 10) ||
			parseInt(process.env.HOSTAPP_RELEASE_ID, 10) ||
			null,
		supervisorReleaseId:
			parseInt(staged.supervisorReleaseId, 10) ||
			parseInt(process.env.SUPERVISOR_RELEASE_ID, 10) ||
			null,
		expected:
			staged.extensionsExpected === true ||
			process.env.EXTENSIONS_EXPECTED === 'true',
	};
};

const CLASS_LABEL = 'io.balena.image.class';
const OVERRIDE_LABEL = 'io.balena.image.override';
const KERNEL_ABI_LABEL = 'io.balena.image.kernel-abi-id';
const KERNEL_VERSION_LABEL = 'io.balena.image.kernel-version';
const OS_VERSION_LABEL = 'io.balena.image.os-version';

// Sourcing the config vars and the find must share one shell
const BOOTENV_LOCATE =
	'. /usr/sbin/balena-config-vars ; ' +
	'find -L "${BALENA_NONENC_BOOT_MOUNTPOINT}" ' +
	'\\( -name bootenv -o -name grubenv \\) | head -1';

/*
 * Field names of the application_profile resource, from the fact type
 * "application1 activates profile name on application2"
 * (open-balena-api/src/balena.sbvr:1001-1005). Kept in one place because they
 * are derived from the model, not observed against a live API.
 */
const PROFILE_ACTIVATOR = 'application1';
const PROFILE_TARGET = 'application2';
const PROFILE_NAME = 'profile_name';

/* -------------------------------------------------------------------------- */
/* Device side                                                                 */
/* -------------------------------------------------------------------------- */

/**
 * Runs a host command over the worker's local link when there is one, and over
 * the cloud SSH gateway otherwise. The local link is preferred because it
 * survives the VPN going down, which HE-PA-05 does on purpose.
 */
const host = async (that, command) => {
	if (that.worker != null && that.link != null) {
		return that.worker.executeCommandInHostOS(command, that.link);
	}
	return that.cloud.executeCommandInHostOS(command, that.balena.uuid);
};

// Splits the trailing exit code off the output, so a real failure is not retried
const run = async (that, command) => {
	const out = (
		// Output without a final newline would join the exit code
		await host(that, `${command} 2>&1 ; printf '\\n%s' $?`)
	).trim();
	const lines = out.split('\n');
	const code = lines.pop().trim();
	return { code: code, output: lines.join('\n').trim() };
};

// Discards output so the result is always a bare exit code
const exitCode = async (that, command) => {
	return host(that, `{ ${command} ; } > /dev/null 2>&1 ; echo $?`);
};

const overlays = async (that) => {
	const out = await host(
		that,
		`balena-engine ps -a --filter "label=${CLASS_LABEL}=overlay"` +
			' --format "{{.Names}}\t{{.Status}}" || true',
	);

	return out
		.split('\n')
		.map((line) => {
			return line.trim();
		})
		.filter((line) => {
			return line !== '';
		})
		.map((line) => {
			const fields = line.split('\t');
			return { name: fields[0], status: (fields[1] || '').trim() };
		});
};

const placement = async (that) => {
	return host(
		that,
		"sed -n '/Overlayed images/,$p' /run/initramfs/initramfs.debug || true",
	);
};

const inventory = async (that) => {
	const list = async (command) => {
		const out = await host(
			that,
			`${command} --filter "label=${CLASS_LABEL}=overlay" || true`,
		);
		return out
			.split('\n')
			.map((line) => {
				return line.trim();
			})
			.filter((line) => {
				return line !== '';
			})
			.sort();
	};

	return {
		containers: await list('balena-engine ps -aq --no-trunc'),
		images: await list('balena-engine images -q --no-trunc'),
	};
};

/**
 * The properties helios gives an activation container. HE-PA-02 asserts these
 * on a helios-made container, which is what keeps the hup suite's local
 * activation in step with production.
 */
const containerShape = async (that, name) => {
	const out = await host(
		that,
		`balena-engine inspect ${name} --format ` +
			"'{{.HostConfig.Runtime}}\t{{.HostConfig.NetworkMode}}\t{{.State.Status}}\t{{.State.ExitCode}}\t{{json .Config.Labels}}' || true",
	);

	const fields = out.trim().split('\t');
	let labels = {};
	try {
		labels = JSON.parse(fields[4]);
	} catch (e) {
		labels = {};
	}

	return {
		runtime: fields[0],
		network: fields[1],
		status: fields[2],
		exitCode: fields[3],
		labels: labels,
	};
};

const imageLabels = async (that, image) => {
	const out = await host(
		that,
		`balena-engine inspect ${image} --format '{{json .Config.Labels}}' || true`,
	);
	try {
		return JSON.parse(out);
	} catch (e) {
		return {};
	}
};

const bootEnv = async (that) => {
	const file = await host(that, `${BOOTENV_LOCATE} || true`);
	if (file === '') {
		return {};
	}

	const listing = await host(that, `grub-editenv ${file} list || true`);

	return listing.split('\n').reduce((acc, line) => {
		const separator = line.indexOf('=');
		if (separator > 0) {
			acc[line.slice(0, separator).trim()] = line.slice(separator + 1).trim();
		}
		return acc;
	}, {});
};

const runningSlot = async (that) => {
	const label = await host(
		that,
		'findmnt --noheadings --output LABEL /mnt/sysroot/active',
	);
	return label.slice(-1);
};

const bootId = async (that) => {
	return host(that, "tr -d '-' < /proc/sys/kernel/random/boot_id");
};

const cmdlineAbi = async (that) => {
	return host(
		that,
		'grep -o "balena_kernel_abi=[^ ]*" /proc/cmdline | cut -d= -f2 || true',
	);
};

const rejectionRecord = async (that) => {
	return host(that, 'cat /mnt/state/override-rejected 2>/dev/null || true');
};

const auditLine = async (that) => {
	return host(
		that,
		'cat /mnt/state/override-health-triggered 2>/dev/null || true',
	);
};

const osVersionId = async (that) => {
	return host(
		that,
		'grep "^VERSION_ID=" /etc/os-release | cut -d= -f2 | tr -d \'"\' || true',
	);
};

// The running half of the equality that puts a release on the overlay-only path
const boardRev = async (that) => {
	return host(
		that,
		'grep "^BALENA_BOARD_REV=" /etc/os-release | cut -d= -f2 | tr -d \'"\' || true',
	);
};

const kernelSha = async (that, path) => {
	const out = await host(that, `sha256sum ${path} 2>/dev/null || true`);
	return out.split(/\s+/)[0] || '';
};

const runtimeRegistered = async (that) => {
	const out = await host(
		that,
		"balena-engine info --format '{{json .Runtimes}}' || true",
	);

	try {
		return Object.keys(JSON.parse(out)).includes('extension');
	} catch (e) {
		return false;
	}
};

const unitResult = async (that, unit) => {
	return host(that, `systemctl show -p Result --value ${unit} || true`);
};

const unitState = async (that, unit) => {
	return host(that, `systemctl show -p ActiveState --value ${unit} || true`);
};

const unitExists = async (that, unit) => {
	return (await exitCode(that, `systemctl cat ${unit}`)) === '0';
};

const captureKernelLog = async (that) => {
	await that.worker.archiveLogs(
		that.id,
		that.link,
		'dmesg --level=emerg,alert,crit,err,warn || true',
	);
};

/* -------------------------------------------------------------------------- */
/* Functional probes                                                           */
/* -------------------------------------------------------------------------- */

const probeTracing = async (that, test) => {
	test.is(
		await exitCode(that, 'command -v perf strace tcpdump ltrace'),
		'0',
		'Should resolve perf, strace, tcpdump and ltrace',
	);

	const versions = [
		'strace -V',
		'ltrace --version',
		'tcpdump --version',
		'perf --version',
	];
	for (const command of versions) {
		test.is(
			await exitCode(that, command),
			'0',
			`Should run "${command}" successfully`,
		);
	}
};

const probeEbpf = async (that, test) => {
	test.is(
		await exitCode(that, 'modprobe hfs'),
		'0',
		'Should load the hfs module from the extension',
	);

	test.is(
		await exitCode(that, 'modprobe nfs'),
		'0',
		'Should load the nfs module from the extension',
	);

	test.is(await exitCode(that, 'bpftool version'), '0', 'Should run bpftool');

	const features = await host(that, 'bpftool feature probe kernel || true');
	// bpftool wording changes between releases
	test.ok(/JIT/i.test(features), 'Should report the JIT compiler');
	test.ok(/BTF/i.test(features), 'Should report BTF support');

	test.is(
		await exitCode(that, 'test -f /sys/kernel/btf/vmlinux'),
		'0',
		'Should expose the kernel BTF blob',
	);
};

const PROBES = {
	tracing: probeTracing,
	ebpf: probeEbpf,
};

const probe = async (that, test, service) => {
	const entry = PROBES[service];

	if (entry == null) {
		test.comment(`No functional probe for ${service}`);
		return;
	}

	await entry(that, test);
};

/* -------------------------------------------------------------------------- */
/* Cloud side                                                                  */
/* -------------------------------------------------------------------------- */

const apiBase = async (that) => {
	return that.cloud.balena.settings.get('apiUrl');
};

/**
 * The profile resources answer on the `resin` API version only: /v6 and /v7
 * return 401.
 */
const resinApi = async (that, method, resource, options) => {
	const base = await apiBase(that);
	const token = await that.cloud.balena.auth.getToken();

	return request({
		method: method,
		uri: `${base}/resin/${resource}`,
		headers: { Authorization: `Bearer ${token}` },
		json: true,
		...options,
	});
};

const releaseInfo = async (that, releaseId) => {
	const releases = await that.cloud.balena.pine.get({
		resource: 'release',
		options: {
			$filter: { id: releaseId },
			$select: ['id', 'commit', 'status', 'is_invalidated', 'semver'],
			$expand: {
				belongs_to__application: {
					$select: ['id', 'slug', 'is_host', 'is_for__device_type'],
					$expand: { is_for__device_type: { $select: ['slug'] } },
				},
			},
		},
	});

	if (releases.length === 0) {
		return null;
	}

	const release = releases[0];
	const app = release.belongs_to__application[0];

	return {
		id: release.id,
		commit: release.commit,
		status: release.status,
		isInvalidated: release.is_invalidated,
		semver: release.semver,
		applicationId: app.id,
		slug: app.slug,
		isHost: app.is_host,
		deviceType: app.is_for__device_type[0].slug,
	};
};

const pinRelease = async (that, releaseId) => {
	return that.cloud.balena.pine.patch({
		resource: 'device',
		options: { $filter: { uuid: that.balena.uuid } },
		body: { should_be_operated_by__release: releaseId },
	});
};

const pinSupervisor = async (that, releaseId) => {
	return that.cloud.balena.pine.patch({
		resource: 'device',
		options: { $filter: { uuid: that.balena.uuid } },
		body: { should_be_managed_by__supervisor_release: releaseId },
	});
};

const devicePins = async (that) => {
	const devices = await that.cloud.balena.pine.get({
		resource: 'device',
		options: {
			$filter: { uuid: that.balena.uuid },
			$select: [
				'id',
				'should_be_operated_by__release',
				'should_be_managed_by__supervisor_release',
				'os_version',
			],
		},
	});
	return devices[0];
};

/**
 * The distinct profile names the release's images carry. The tests never create
 * image_profile rows: the build does.
 */
const discoverProfiles = async (that, releaseId) => {
	const rows = await resinApi(that, 'GET', 'image_profile', {
		qs: {
			$select: 'profile_name',
			$filter: `release_image/any(ri:ri/is_part_of__release eq ${releaseId})`,
		},
	});

	const names = (rows.d || []).map((row) => {
		return row.profile_name;
	});
	return [...new Set(names)].sort();
};

// The suite context holds the fleet slug, so the id is resolved once and passed in
const applicationId = async (that, slug) => {
	const apps = await that.cloud.balena.pine.get({
		resource: 'application',
		options: { $filter: { slug: slug }, $select: ['id'] },
	});
	return apps.length === 0 ? null : apps[0].id;
};

const activateProfiles = async (that, names, activatorId, targetId) => {
	const results = [];
	for (const name of names) {
		results.push(
			await resinApi(that, 'POST', 'application_profile', {
				body: {
					[PROFILE_ACTIVATOR]: activatorId,
					[PROFILE_TARGET]: targetId,
					[PROFILE_NAME]: name,
				},
			}),
		);
	}
	return results;
};

const deactivateProfiles = async (that, names, activatorId, targetId) => {
	for (const name of names) {
		await resinApi(that, 'DELETE', 'application_profile', {
			qs: {
				$filter:
					`${PROFILE_ACTIVATOR} eq ${activatorId} and ` +
					`${PROFILE_TARGET} eq ${targetId} and ` +
					`${PROFILE_NAME} eq '${name}'`,
			},
		});
	}
};

const listActivations = async (that, activatorId, targetId) => {
	const rows = await resinApi(that, 'GET', 'application_profile', {
		qs: {
			$select: PROFILE_NAME,
			$filter:
				`${PROFILE_ACTIVATOR} eq ${activatorId} and ` +
				`${PROFILE_TARGET} eq ${targetId}`,
		},
	});

	return (rows.d || [])
		.map((row) => {
			return row[PROFILE_NAME];
		})
		.sort();
};

// journalctl --list-boots is the only count that survives a reboot
const bootCount = async (that) => {
	const out = await host(
		that,
		'journalctl --no-pager --list-boots | wc -l || true',
	);
	return parseInt(out, 10) || 0;
};

const unitActiveEnter = async (that, unit) => {
	return host(
		that,
		`systemctl show -p ActiveEnterTimestampMonotonic --value ${unit} || true`,
	);
};

// What the API is about to serve the device, archived at each pin and toggle
const targetState = async (that) => {
	const base = await apiBase(that);
	const token = await that.cloud.balena.auth.getToken();

	return request({
		method: 'GET',
		uri: `${base}/device/v3/${that.balena.uuid}/state`,
		headers: { Authorization: `Bearer ${token}` },
		json: true,
	});
};

/**
 * Reads a target change now rather than on the next poll, measured at 922 s.
 * Never restart core-next: a restart breaks the helios log sink.
 */
const nudgeHelios = async (that) => {
	const out = await host(
		that,
		"curl -s -o /dev/null -w '%{http_code}' -X POST " +
			"-H 'Content-Type: application/json' -d '{}' " +
			'http://127.0.0.1:48484/v1/update',
	);
	return out.trim();
};

/**
 * Spec question 2. The supervisor delivers core-next from the registry and the
 * image reference may carry no helios tag, so try the image labels first and
 * fall back to asking the binary.
 */
const heliosVersion = async (that) => {
	const labelled = await host(
		that,
		"balena-engine inspect core-next --format '{{index .Config.Labels " +
			'"org.opencontainers.image.version"}}\' 2>/dev/null || true',
	);
	if (labelled !== '' && labelled !== '<no value>') {
		return labelled;
	}

	const reported = await host(
		that,
		'balena-engine exec core-next helios --version 2>/dev/null || true',
	);
	// "helios 0.28.2" or bare "0.28.2"
	const match = reported.match(/([0-9]+\.[0-9]+\.[0-9]+[^\s]*)/);
	return match == null ? '' : match[1];
};

const supervisorContainers = async (that) => {
	const out = await host(
		that,
		'balena-engine ps -a --format "{{.Names}}\t{{.Image}}\t{{.Status}}" || true',
	);
	return out
		.split('\n')
		.map((line) => {
			return line.trim();
		})
		.filter((line) => {
			return line !== '';
		});
};

module.exports = {
	activateProfiles,
	applicationId,
	bootCount,
	apiBase,
	auditLine,
	boardRev,
	bootEnv,
	bootId,
	captureKernelLog,
	cmdlineAbi,
	containerShape,
	deactivateProfiles,
	devicePins,
	discoverProfiles,
	exitCode,
	heliosVersion,
	host,
	imageLabels,
	inventory,
	kernelSha,
	listActivations,
	nudgeHelios,
	osVersionId,
	overlays,
	pinRelease,
	pinSupervisor,
	placement,
	probe,
	rejectionRecord,
	releaseInfo,
	resinApi,
	run,
	runningSlot,
	runtimeRegistered,
	stagedConfig,
	supervisorContainers,
	targetState,
	unitActiveEnter,
	unitExists,
	unitResult,
	unitState,
	CLASS_LABEL,
	KERNEL_ABI_LABEL,
	KERNEL_VERSION_LABEL,
	OS_VERSION_LABEL,
	OVERRIDE_LABEL,
};
