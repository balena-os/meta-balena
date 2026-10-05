/*
 * Copyright 2026 balena
 *
 * @license Apache-2.0
 */

'use strict';

const { existsSync, readdirSync } = require('fs');
const { basename, join } = require('path');

// CI stages the images here because the suite is the only uploaded directory
const EXTENSIONS_DIR = join(__dirname, '..', 'extensions');

const DUT_STAGING_DIR = '/mnt/data/resin-data';

const CLASS_LABEL = 'io.balena.image.class';
const OS_VERSION_LABEL = 'io.balena.image.os-version';
const KERNEL_ABI_LABEL = 'io.balena.image.kernel-abi-id';

// Sourcing the config vars and the find must share one shell
const BOOTENV_LOCATE =
	'. /usr/sbin/balena-config-vars ; ' +
	'find -L "${BALENA_NONENC_BOOT_MOUNTPOINT}" ' +
	'\\( -name bootenv -o -name grubenv \\) | head -1';

const containerName = (service) => {
	return `${service}_leviathan`;
};

/**
 * Runs a command on the DUT and splits the trailing exit code off the output.
 * The trailing code stops executeCommandInHostOS retrying a real failure for
 * five minutes.
 */
const run = async (that, command) => {
	const out = (
		await that.worker.executeCommandInHostOS(
			// Output without a final newline would join the exit code
			`${command} 2>&1 ; printf '\\n%s' $?`,
			that.link,
		)
	).trim();
	const lines = out.split('\n');
	const code = lines.pop().trim();
	return { code: code, output: lines.join('\n').trim() };
};

// Discards output so the result is always a bare exit code
const exitCode = async (that, command) => {
	return that.worker.executeCommandInHostOS(
		`{ ${command} ; } > /dev/null 2>&1 ; echo $?`,
		that.link,
	);
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
		let attempts = 0;
		let done = false;
		while (!done) {
			try {
				await that.worker.sendFile(
					staged[service],
					`${DUT_STAGING_DIR}/`,
					that.link,
				);
				done = true;
			} catch (e) {
				if (attempts < 5) {
					test.comment(`Error while sending ${service}... Retrying`);
					attempts++;
				} else {
					throw new Error(
						`Failed to send extension ${service} to dut: ${e.message}`,
					);
				}
			}
		}
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
	await that.worker.executeCommandInHostOS(
		`balena-engine rmi -f ${ref} || true`,
		that.link,
	);
};

const imageLabels = async (that, ref) => {
	const inspected = await run(
		that,
		`balena-engine inspect --format '{{json .Config.Labels}}' ${ref}`,
	);
	if (inspected.code !== '0') {
		throw new Error(`Failed to inspect ${ref}: ${inspected.output}`);
	}

	let labels;
	try {
		labels = JSON.parse(inspected.output);
	} catch (e) {
		// The engine merges stderr here, so name the output in the failure
		throw new Error(
			`Could not parse the labels of ${ref}: ${inspected.output}`,
		);
	}

	return labels === null ? {} : labels;
};

const kernelAbiId = (labels) => {
	return labels[KERNEL_ABI_LABEL] || '';
};

/**
 * Matches the os-version label against a VERSION_ID. The label is a comma
 * separated glob list; a missing or empty label always matches.
 */
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

// Creates the container in the shape helios creates it, then waits for it
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

	return that.worker.executeCommandInHostOS(
		`balena-engine wait ${name}`,
		that.link,
	);
};

const withdrawLocal = async (that, service) => {
	await that.worker.executeCommandInHostOS(
		`balena-engine rm -f ${containerName(service)} || true`,
		that.link,
	);
};

// Listed by label because a name tells nothing about what was overlayed
const overlays = async (that) => {
	const out = await that.worker.executeCommandInHostOS(
		`balena-engine ps -a --filter "label=${CLASS_LABEL}=overlay"` +
			' --format "{{.Names}}\t{{.Status}}" || true',
		that.link,
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

// IDs, so a removed and recreated object counts as a change
const inventory = async (that) => {
	const list = async (command) => {
		const out = await that.worker.executeCommandInHostOS(
			`${command} --filter "label=${CLASS_LABEL}=overlay" || true`,
			that.link,
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

const placement = async (that) => {
	return that.worker.executeCommandInHostOS(
		"sed -n '/Overlayed images/,$p' /run/initramfs/initramfs.debug || true",
		that.link,
	);
};

const bootEnv = async (that) => {
	const file = await that.worker.executeCommandInHostOS(
		`${BOOTENV_LOCATE} || true`,
		that.link,
	);
	if (file === '') {
		return {};
	}

	const listing = await that.worker.executeCommandInHostOS(
		`grub-editenv ${file} list || true`,
		that.link,
	);

	return listing.split('\n').reduce((acc, line) => {
		const separator = line.indexOf('=');
		if (separator > 0) {
			acc[line.slice(0, separator).trim()] = line.slice(separator + 1).trim();
		}
		return acc;
	}, {});
};

// The manager names slots A and B after the root filesystem label
const runningSlot = async (that) => {
	const label = await that.worker.executeCommandInHostOS(
		'findmnt --noheadings --output LABEL /mnt/sysroot/active',
		that.link,
	);
	return label.slice(-1);
};

// journalctl --list-boots prints boot ids without dashes
const bootId = async (that) => {
	return that.worker.executeCommandInHostOS(
		"tr -d '-' < /proc/sys/kernel/random/boot_id",
		that.link,
	);
};

const previousBootId = async (that) => {
	return that.worker.executeCommandInHostOS(
		"journalctl --list-boots --no-pager | awk '$1 == \"-1\" {print $2}'",
		that.link,
	);
};

const journalCount = async (that, boot, pattern) => {
	const count = await that.worker.executeCommandInHostOS(
		`journalctl --no-pager -b ${boot} | grep -c "${pattern}" || true`,
		that.link,
	);
	return parseInt(count, 10);
};

// Recorded, not asserted: the spec asks for evidence on every boot
const captureKernelLog = async (that) => {
	await that.worker.archiveLogs(
		that.id,
		that.link,
		'dmesg --level=emerg,alert,crit,err,warn || true',
	);
};

const cmdlineAbi = async (that) => {
	return that.worker.executeCommandInHostOS(
		'grep -o "balena_kernel_abi=[^ ]*" /proc/cmdline | cut -d= -f2 || true',
		that.link,
	);
};

const rejectionRecord = async (that) => {
	return that.worker.executeCommandInHostOS(
		'cat /mnt/state/override-rejected 2>/dev/null || true',
		that.link,
	);
};

// Holds the last HUP rejection only; nothing removes it
const auditLine = async (that) => {
	return that.worker.executeCommandInHostOS(
		'cat /mnt/state/override-health-triggered 2>/dev/null || true',
		that.link,
	);
};

const activeSlot = async (that) => {
	return that.worker.executeCommandInHostOS(
		'findmnt --noheadings --canonicalize --output SOURCE /mnt/sysroot/active',
		that.link,
	);
};

const osVersionId = async (that) => {
	return that.worker.executeCommandInHostOS(
		'grep "^VERSION_ID=" /etc/os-release | cut -d= -f2 | tr -d \'"\' || true',
		that.link,
	);
};

const runtimeRegistered = async (that) => {
	const out = await that.worker.executeCommandInHostOS(
		"balena-engine info --format '{{json .Runtimes}}' || true",
		that.link,
	);

	try {
		return Object.keys(JSON.parse(out)).includes('extension');
	} catch (e) {
		return false;
	}
};

const unitResult = async (that, unit) => {
	return that.worker.executeCommandInHostOS(
		`systemctl show -p Result --value ${unit} || true`,
		that.link,
	);
};

const unitExists = async (that, unit) => {
	return (await exitCode(that, `systemctl cat ${unit}`)) === '0';
};

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

	const features = await that.worker.executeCommandInHostOS(
		'bpftool feature probe kernel || true',
		that.link,
	);
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

module.exports = {
	activateLocal,
	activeSlot,
	artifacts,
	auditLine,
	bootEnv,
	bootId,
	captureKernelLog,
	cmdlineAbi,
	containerName,
	exitCode,
	imageLabels,
	inventory,
	journalCount,
	kernelAbiId,
	loadImage,
	osVersionId,
	osVersionMatches,
	overlays,
	placement,
	previousBootId,
	probe,
	rejectionRecord,
	removeImage,
	run,
	runningSlot,
	runtimeRegistered,
	sendArtifacts,
	unitExists,
	unitResult,
	withdrawLocal,
};
