/*
 * Copyright 2026 balena
 *
 * @license Apache-2.0
 */

'use strict';

const ext = require('./extensions');

const CONFIG_JSON = '/mnt/boot/config.json';
const FLEET_CONFIG = '/tmp/seed-fleet.json';

// 20 min at 5 s per try, the same bound as the cloud suite
const HELIOS_TRIES = 240;
const HELIOS_INTERVAL = 5000;

// A draft needs the update-balena-supervisor fix the seed lacks
const latestSupervisorRelease = async (that) => {
	const slug = `balena_os/${that.suite.deviceType.data.arch}-supervisor`;
	const [release] = await that.sdk.balena.pine.get({
		resource: 'release',
		options: {
			$select: 'id',
			$filter: {
				is_final: true,
				is_invalidated: false,
				status: 'success',
				belongs_to__application: {
					$any: { $alias: 'a', $expr: { a: { slug: slug } } },
				},
			},
			$orderby: { created_at: 'desc' },
			$top: 1,
		},
	});

	if (release == null) {
		throw new Error(`No final supervisor release in ${slug}`);
	}
	return release.id;
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

// The supervisor delivers core-next, so a local mode device has none
const deliverHelios = async (that, test) => {
	await joinFleet(that, test);

	await that.sdk.balena.pine.patch({
		resource: 'device',
		options: {
			$filter: { uuid: that.suite.options.balenaOS.config.uuid },
		},
		body: { should_be_managed_by__release: await latestSupervisorRelease(that) },
	});

	// The timer would otherwise delay the update by hours
	await ext.host(that, 'systemctl start --no-block update-balena-supervisor');

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
