/*
 * Copyright 2026 balena
 *
 * @license Apache-2.0
 */

'use strict';

const request = require('request-promise');
const { existsSync, readFileSync } = require('fs');
const { join } = require('path');

const common = require('./extensions-common');

const { CLASS_LABEL, exitCode, host } = common;

// Errors carry the request options, so drop the token
const apiRequest = async (options) => {
	try {
		return await request(options);
	} catch (error) {
		const body = error.error != null ? JSON.stringify(error.error) : error.message;
		throw new Error(
			`${options.method} ${options.uri.split('?')[0]}: ${error.statusCode || ''} ${body}`,
		);
	}
};

// A workflow env var cannot reach a test.
// CI writes this file. Manual runs use process.env.
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
	};
};

// The API names the roles after the verb (balena.sbvr:1001)
const PROFILE_ACTIVATOR = 'application';
const PROFILE_TARGET = 'on__application';
const PROFILE_NAME = 'activates__profile_name';

// The properties helios gives an activation container
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

// A matching revision selects the overlay-only path
const boardRev = async (that) => {
	return host(
		that,
		'grep "^BALENA_BOARD_REV=" /etc/os-release | cut -d= -f2 | tr -d \'"\' || true',
	);
};

const unitState = async (that, unit) => {
	return host(that, `systemctl show -p ActiveState --value ${unit} || true`);
};

// vfat keeps no modes, so cp restores the original
const cmdlineFile = (path) => {
	return {
		path: path,
		add: (arg) => {
			return (
				`cp ${path} ${path}.leviathan && ` +
				`sed -i '1s/$/ ${arg}/' ${path} && sync -f ${path}`
			);
		},
		restore:
			`[ -f ${path}.leviathan ] && mv ${path}.leviathan ${path} && ` +
			`sync -f ${path}`,
	};
};

// kexec passes this command line to the main kernel.
// Add one hook for each boot file.
const CMDLINE_HOOKS = [cmdlineFile('/mnt/boot/cmdline.txt')];

// Returns null when no hook applies on this device.
// add and restore take effect on the next boot.
const cmdlineHook = async (that) => {
	for (const hook of CMDLINE_HOOKS) {
		if ((await exitCode(that, `test -f ${hook.path}`)) === '0') {
			return {
				path: hook.path,
				add: (arg) => {
					return exitCode(that, hook.add(arg));
				},
				restore: () => {
					return exitCode(that, hook.restore);
				},
			};
		}
	}
	return null;
};

const cmdlineHas = async (that, arg) => {
	return (await exitCode(that, `grep -qw ${arg} /proc/cmdline`)) === '0';
};

const apiBase = async (that) => {
	return that.cloud.balena.settings.get('apiUrl');
};

// Only the resin API version serves profile resources
const resinApi = async (that, method, resource, options = {}) => {
	const base = await apiBase(that);
	const token = await that.cloud.balena.auth.getToken();
	const { qs, ...rest } = options;

	// The API rejects percent-encoded OData syntax, which qs produces
	const query =
		qs == null
			? ''
			: '?' +
				Object.entries(qs)
					.map(([key, value]) => {
						return `${key}=${encodeURI(String(value))}`;
					})
					.join('&');

	return apiRequest({
		method: method,
		uri: `${base}/resin/${resource}${query}`,
		headers: { Authorization: `Bearer ${token}` },
		json: true,
		...rest,
	});
};

const releaseInfo = async (that, releaseId) => {
	const releases = await that.cloud.balena.pine.get({
		resource: 'release',
		options: {
			$filter: { id: releaseId },
			$select: [
				'id',
				'commit',
				'status',
				'is_invalidated',
				'semver',
				'composition',
			],
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

	// The released composition is the artifact under test.
	// A build matrix does not list every shipped service.
	const services = Object.values(release.composition?.services ?? {});

	// Every hostapp release carries at least the hostapp service
	if (services.length === 0) {
		throw new Error(`Release ${release.id} returned no composition services`);
	}

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
		shipsExtensions: services.some((service) => {
			return (service.labels?.[CLASS_LABEL] ?? 'overlay') !== 'hostapp';
		}),
	};
};

const pinRelease = async (that, releaseId) => {
	return that.cloud.balena.pine.patch({
		resource: 'device',
		options: { $filter: { uuid: that.balena.uuid } },
		body: { should_be_operated_by__release: releaseId },
	});
};

// The build creates the image_profile rows, not the tests
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

// Callers resolve the id once from the fleet slug
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

// Only the journalctl boot count survives a reboot
const bootCount = async (that) => {
	const out = await host(
		that,
		'journalctl --no-pager --list-boots | wc -l || true',
	);
	return parseInt(out, 10) || 0;
};

// The state that the API serves to the device
const targetState = async (that) => {
	const base = await apiBase(that);
	const token = await that.cloud.balena.auth.getToken();

	return apiRequest({
		method: 'GET',
		uri: `${base}/device/v3/${that.balena.uuid}/state`,
		headers: { Authorization: `Bearer ${token}` },
		json: true,
	});
};

// Skips the 922 s poll interval.
// A core-next restart breaks the helios log sink.
const nudgeHelios = async (that) => {
	const out = await host(
		that,
		"curl -s -o /dev/null -w '%{http_code}' -X POST " +
			"-H 'Content-Type: application/json' -d '{}' " +
			'http://127.0.0.1:48484/v1/update',
	);
	return out.trim();
};

module.exports = {
	...common,
	activateProfiles,
	applicationId,
	boardRev,
	bootCount,
	cmdlineHas,
	cmdlineHook,
	containerShape,
	deactivateProfiles,
	discoverProfiles,
	listActivations,
	nudgeHelios,
	pinRelease,
	releaseInfo,
	stagedConfig,
	targetState,
	unitState,
};
