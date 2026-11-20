/*
 * Copyright 2026 balena
 *
 * @license Apache-2.0
 */

'use strict';

const { existsSync, readFileSync } = require('fs');
const { join } = require('path');

const ext = require('./extensions');

const CONFIG_JSON = '/mnt/boot/config.json';
const FLEET_CONFIG = '/tmp/seed-fleet.json';

// Staged like the cloud suite's hostapp.json
const STAGED_CONFIG = join(__dirname, '..', 'hostapp.json');

// 20 min at 5 s per try, the same bound as the cloud suite
const HELIOS_TRIES = 240;
const HELIOS_INTERVAL = 5000;

// Only a draft supervisor carries helios with overlay support
const stagedSupervisorRelease = () => {
	const staged = existsSync(STAGED_CONFIG)
		? JSON.parse(readFileSync(STAGED_CONFIG, 'utf8'))
		: {};
	const id =
		parseInt(staged.supervisorReleaseId, 10) ||
		parseInt(process.env.SUPERVISOR_RELEASE_ID, 10);

	if (!id) {
		throw new Error(
			`No supervisor release in ${STAGED_CONFIG} or SUPERVISOR_RELEASE_ID`,
		);
	}
	return id;
};

const joinFleet = async (that, test) => {
	const { balena } = that.sdk;
	const { uuid } = that.suite.options.balenaOS.config;

	const app = await balena.models.application.create({
		name: `hup-seed-${uuid.slice(0, 7)}`,
		deviceType: that.suite.deviceType.slug,
		organization: that.suite.options.balena.organization,
	});
	that.suite.teardown.register(() => {
		return balena.models.application.remove(app.slug);
	});

	const config = await balena.models.os.getConfig(app.slug, {
		version: await ext.osVersionId(that),
	});
	const device = await balena.models.device.register(app.slug, uuid);

	const fleet = Buffer.from(
		JSON.stringify({
			...config,
			uuid: uuid,
			deviceApiKey: device.api_key,
			deviceId: device.id,
			// Keeps SSH open once the fleet config merges
			developmentMode: true,
		}),
	).toString('base64');

	// A local mode supervisor ignores the fleet
	test.is(
		await ext.exitCode(
			that,
			`echo ${fleet} | base64 -d > ${FLEET_CONFIG}` +
				` && jq -s '.[0] * .[1] | del(.localMode)' ${CONFIG_JSON} ${FLEET_CONFIG}` +
				` > ${FLEET_CONFIG}.merged` +
				` && cp ${FLEET_CONFIG}.merged ${CONFIG_JSON}` +
				` && rm ${FLEET_CONFIG} ${FLEET_CONFIG}.merged` +
				' && systemctl restart balena-supervisor',
		),
		'0',
		'Should join the previous release to a fleet',
	);
};

const deviceSupervisor = async (that) => {
	const [device] = await that.sdk.balena.pine.get({
		resource: 'device',
		options: {
			$select: ['supervisor_version', 'should_be_managed_by__release'],
			$filter: { uuid: that.suite.options.balenaOS.config.uuid },
		},
	});
	return {
		version: device.supervisor_version,
		pin: device.should_be_managed_by__release?.__id ?? null,
	};
};

// The supervisor delivers core-next, so a local mode device has none
const deliverHelios = async (that, test) => {
	await joinFleet(that, test);

	// The API repins to the first reported supervisor version
	await test.resolves(
		that.utils.waitUntil(
			async () => {
				return (await deviceSupervisor(that)).version != null;
			},
			false,
			HELIOS_TRIES,
			HELIOS_INTERVAL,
		),
		'Should report the seed supervisor version',
	);

	const releaseId = stagedSupervisorRelease();
	await that.sdk.balena.pine.patch({
		resource: 'device',
		options: {
			$filter: { uuid: that.suite.options.balenaOS.config.uuid },
		},
		body: { should_be_managed_by__release: releaseId },
	});

	// The timer would otherwise delay the update by hours
	await ext.host(that, 'systemctl start update-balena-supervisor');
	await test.resolves(
		that.utils.waitUntil(
			async () => {
				return (
					(await ext.host(
						that,
						'systemctl is-active update-balena-supervisor || true',
					)) !== 'active'
				);
			},
			false,
			HELIOS_TRIES,
			HELIOS_INTERVAL,
		),
		'Should finish the supervisor update',
	);
	test.is(
		(await deviceSupervisor(that)).pin,
		releaseId,
		'Should keep the staged supervisor pin',
	);
	// os-config can restart the old supervisor during the pull
	await ext.host(that, 'systemctl restart balena-supervisor');

	await test.resolves(
		that.utils.waitUntil(
			async () => {
				return (await ext.heliosVersion(that)) !== '';
			},
			false,
			HELIOS_TRIES,
			HELIOS_INTERVAL,
		),
		'Should run core-next on the previous release',
	);
};

module.exports = { deliverHelios };
