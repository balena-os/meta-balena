/*
 * Copyright 2026 balena
 *
 * @license Apache-2.0
 */

'use strict';

const { existsSync, readdirSync } = require('fs');
const { basename, join } = require('path');

const common = require('./extensions-common');

const {
	OS_VERSION_LABEL,
	exitCode,
	host,
	inventory,
	run,
	sendFile,
} = common;

// CI stages the images in the uploaded suite directory
const EXTENSIONS_DIR = join(__dirname, '..', 'extensions');
const DUT_STAGING_DIR = '/mnt/data/resin-data';

const containerName = (service) => {
	return `${service}_leviathan`;
};

const artifacts = () => {
	if (!existsSync(EXTENSIONS_DIR)) {
		return {};
	}

	return readdirSync(EXTENSIONS_DIR)
		.filter((entry) => {
			return entry.endsWith('.docker');
		})
		.reduce((acc, entry) => {
			acc[basename(entry, '.docker')] = join(EXTENSIONS_DIR, entry);
			return acc;
		}, {});
};

const sendArtifacts = async (that, test) => {
	const staged = artifacts();
	const sent = {};

	for (const service of Object.keys(staged)) {
		await sendFile(
			that,
			test,
			staged[service],
			`${DUT_STAGING_DIR}/`,
			`extension ${service}`,
		);
		sent[service] = `${DUT_STAGING_DIR}/${basename(staged[service])}`;
	}

	return sent;
};

const loadImage = async (that, service, dutPath) => {
	const loaded = await run(that, `balena-engine load -i ${dutPath}`);
	if (loaded.code !== '0') {
		throw new Error(`Failed to load extension ${service}: ${loaded.output}`);
	}

	// An untagged archive reports an id instead of a reference
	const match = loaded.output.match(/Loaded image(?: ID)?:\s*(\S+)/);
	if (match === null) {
		throw new Error(
			`Could not parse the loaded image for ${service}: ${loaded.output}`,
		);
	}

	return match[1];
};

const removeImage = async (that, ref) => {
	await host(that, `balena-engine rmi -f ${ref} || true`);
};

// The label is a comma separated glob list.
// A missing or empty label matches.
const osVersionMatches = (labels, versionId) => {
	const patterns = (labels[OS_VERSION_LABEL] || '')
		.split(',')
		.map((pattern) => {
			return pattern.trim();
		})
		.filter((pattern) => {
			return pattern !== '';
		});

	if (patterns.length === 0) {
		return true;
	}

	return patterns.some((pattern) => {
		const expr = pattern
			.replace(/[.+^${}()|[\]\\]/g, '\\$&')
			.replace(/\*/g, '.*')
			.replace(/\?/g, '.');
		return new RegExp(`^${expr}$`).test(versionId);
	});
};

// Creates the container as helios does, then waits
const activateLocal = async (that, service, ref) => {
	const name = containerName(service);

	const created = await run(
		that,
		`balena-engine create --name ${name} --runtime extension --network none` +
			` --label io.balena.service-name=${service}` +
			` --label io.balena.private.image=${ref}` +
			' --label io.balena.private.boot-id=$(cat /proc/sys/kernel/random/boot_id)' +
			' --label io.balena.private.runtime=extension' +
			` ${ref}`,
	);
	if (created.code !== '0') {
		throw new Error(`Failed to create ${name}: ${created.output}`);
	}

	const started = await run(that, `balena-engine start ${name}`);
	if (started.code !== '0') {
		throw new Error(`Failed to start ${name}: ${started.output}`);
	}

	return host(that, `balena-engine wait ${name}`);
};

const withdrawLocal = async (that, service) => {
	await host(that, `balena-engine rm -f ${containerName(service)} || true`);
};

const previousBootId = async (that, offset = -1) => {
	return host(
		that,
		`journalctl --list-boots --no-pager | awk '$1 == "${offset}" {print $2}'`,
	);
};

const journalCount = async (that, boot, pattern) => {
	const count = await host(
		that,
		`journalctl --no-pager -b ${boot} | grep -c "${pattern}" || true`,
	);
	return parseInt(count, 10);
};

const activeSlot = async (that) => {
	return host(
		that,
		'findmnt --noheadings --canonicalize --output SOURCE /mnt/sysroot/active',
	);
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
			return (await host(that, `systemctl is-active ${unit} || true`)) === 'active';
		},
		message,
	);
};

const markerIs = async (that, test, marker, wanted, message) => {
	// 0 means file exists, 1 means file does not exist
	test.is(
		await exitCode(that, `test -f /mnt/state/${marker}`),
		wanted,
		message,
	);
};

// Retention holds on both sides of the HUP
const assertInventory = async (that, test, before, when) => {
	test.same(
		await inventory(that),
		before,
		`Should keep every overlay container and image ${when}`,
	);
};

// HUPs the build and leaves the inactive slot ready to break
const hupWithShortHealthWindow = async (that, test) => {
	await that.hup.doHUP(that, test, 'local', that.link);

	test.is(
		await host(that, that.hup.REDUCE_HEALTH_WINDOW),
		'0', // only confirms the command ran, not that sed replaced anything
		'Should reduce rollback-health timeout to 3x10s',
	);
};

// Override claims assert the running kernel before this gate
const probe = async (that, test, service) => {
	return common.probe(that, test, service, true);
};

module.exports = {
	...common,
	activateLocal,
	activeSlot,
	artifacts,
	assertInventory,
	containerName,
	hupWithShortHealthWindow,
	journalCount,
	loadImage,
	markerIs,
	osVersionMatches,
	previousBootId,
	probe,
	removeImage,
	sendArtifacts,
	waitFor,
	waitForUnit,
	withdrawLocal,
};
