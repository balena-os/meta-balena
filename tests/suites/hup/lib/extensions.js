/*
 * Copyright 2026 balena
 *
 * @license Apache-2.0
 */

'use strict';

const { execFile } = require('child_process');
const {
	copyFileSync,
	cpSync,
	existsSync,
	mkdirSync,
	mkdtempSync,
	readdirSync,
	rmSync,
} = require('fs');
const { tmpdir } = require('os');
const { basename, join } = require('path');
const { promisify } = require('util');

const execFileAsync = promisify(execFile);

// CI stages the images here because the suite is the only uploaded directory
const EXTENSIONS_DIR = join(__dirname, '..', 'extensions');
const HEADERS_DIR = join(__dirname, '..', 'headers');
const CRC_GATE_ASSETS = join(__dirname, '..', 'assets', 'crc-gate');

const DUT_STAGING_DIR = '/mnt/data/resin-data';
const CRC_GATE_DIR = `${DUT_STAGING_DIR}/crc-gate`;
const CRC_GATE_IMAGE = 'crc-gate';

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
 * Runs a host command over the worker's local link when there is one, and over
 * the cloud SSH gateway otherwise. Kept identical to the cloud suite's copy.
 */
const host = async (that, command) => {
	if (that.worker != null && that.link != null) {
		return that.worker.executeCommandInHostOS(command, that.link);
	}
	return that.cloud.executeCommandInHostOS(command, that.balena.uuid);
};

/**
 * Runs a command on the DUT and splits the trailing exit code off the output.
 * The trailing code stops executeCommandInHostOS retrying a real failure for
 * five minutes.
 */
const run = async (that, command) => {
	// Output without a final newline would join the exit code
	const out = (await host(that, `${command} 2>&1 ; printf '\\n%s' $?`)).trim();
	const lines = out.split('\n');
	const code = lines.pop().trim();
	return { code: code, output: lines.join('\n').trim() };
};

// Throws with the output, so a failed step names its cause
const mustRun = async (that, command) => {
	const result = await run(that, `{ ${command} ; }`);
	if (result.code !== '0') {
		throw new Error(`"${command}" exited ${result.code}: ${result.output}`);
	}
	return result.output;
};

// Discards output so the result is always a bare exit code
const exitCode = async (that, command) => {
	return host(that, `{ ${command} ; } > /dev/null 2>&1 ; echo $?`);
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

const sendFile = async (that, test, path, destination, what) => {
	for (let attempt = 1; ; attempt++) {
		try {
			await that.worker.sendFile(path, destination, that.link);
			return;
		} catch (e) {
			if (attempt > 5) {
				throw new Error(`Failed to send ${what} to dut: ${e.message}`);
			}
			test.comment(`Error while sending ${what}... Retrying`);
		}
	}
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

const inspectLabels = async (that, type, ref) => {
	const inspected = await run(
		that,
		`balena-engine inspect --type ${type} --format '{{json .Config.Labels}}' ${ref}`,
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

const imageLabels = async (that, ref) => {
	return inspectLabels(that, 'image', ref);
};

// Both activateLocal and helios label the container this way
const overlayContainer = async (that, service) => {
	const ids = (
		await mustRun(
			that,
			'balena-engine ps -aq --no-trunc' +
				` --filter label=io.balena.service-name=${service}` +
				` --filter label=${CLASS_LABEL}=overlay`,
		)
	)
		.split('\n')
		.map((line) => {
			return line.trim();
		})
		.filter((line) => {
			return line !== '';
		});

	if (ids.length !== 1) {
		throw new Error(
			`Expected one overlay container for ${service}, found ${ids.length}`,
		);
	}

	return ids[0];
};

// The engine copies the image labels into the container config
const overlayLabels = async (that, service) => {
	return inspectLabels(
		that,
		'container',
		await overlayContainer(that, service),
	);
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

	return host(that, `balena-engine wait ${name}`);
};

const withdrawLocal = async (that, service) => {
	await host(that, `balena-engine rm -f ${containerName(service)} || true`);
};

// Listed by label because a name tells nothing about what was overlayed
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

// IDs, so a removed and recreated object counts as a change
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

const placement = async (that) => {
	return host(
		that,
		"sed -n '/Overlayed images/,$p' /run/initramfs/initramfs.debug || true",
	);
};

const keyValues = (text) => {
	return text.split('\n').reduce((acc, line) => {
		const separator = line.indexOf('=');
		if (separator > 0) {
			acc[line.slice(0, separator).trim()] = line.slice(separator + 1).trim();
		}
		return acc;
	}, {});
};

const bootEnv = async (that) => {
	const file = await host(that, `${BOOTENV_LOCATE} || true`);
	if (file === '') {
		return {};
	}

	return keyValues(await host(that, `grub-editenv ${file} list || true`));
};

// The manager names slots A and B after the root filesystem label
const runningSlot = async (that) => {
	const label = await host(
		that,
		'findmnt --noheadings --output LABEL /mnt/sysroot/active',
	);
	return label.slice(-1);
};

// journalctl --list-boots prints boot ids without dashes
const bootId = async (that) => {
	return host(that, "tr -d '-' < /proc/sys/kernel/random/boot_id");
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

// Recorded, not asserted: the spec asks for evidence on every boot
const captureKernelLog = async (that) => {
	await that.worker.archiveLogs(
		that.id,
		that.link,
		'dmesg --level=emerg,alert,crit,err,warn || true',
	);
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

// Holds the last HUP rejection only; nothing removes it
const auditLine = async (that) => {
	return host(
		that,
		'cat /mnt/state/override-health-triggered 2>/dev/null || true',
	);
};

const activeSlot = async (that) => {
	return host(
		that,
		'findmnt --noheadings --canonicalize --output SOURCE /mnt/sysroot/active',
	);
};

const osVersionId = async (that) => {
	return host(
		that,
		'grep "^VERSION_ID=" /etc/os-release | cut -d= -f2 | tr -d \'"\' || true',
	);
};

// The supervisor suffixes the name, so match by prefix
const heliosVersion = async (that) => {
	const labelled = await host(
		that,
		"balena-engine inspect $(balena-engine ps -q --filter name=^core-next | head -1) --format '{{index .Config.Labels " +
			'"org.opencontainers.image.version"}}\' 2>/dev/null || true',
	);
	if (labelled !== '' && labelled !== '<no value>') {
		return labelled;
	}

	const reported = await host(
		that,
		'balena-engine exec $(balena-engine ps -q --filter name=^core-next | head -1) helios --version 2>/dev/null || true',
	);
	const match = reported.match(/([0-9]+\.[0-9]+\.[0-9]+[^\s]*)/);
	return match == null ? '' : match[1];
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

const unitExists = async (that, unit) => {
	return (await exitCode(that, `systemctl cat ${unit}`)) === '0';
};

const stagedHeaders = (service) => {
	const headers = {
		base: join(HEADERS_DIR, 'base.tar.gz'),
		ext: join(HEADERS_DIR, `${service}.tar.gz`),
	};
	for (const path of Object.values(headers)) {
		if (!existsSync(path)) {
			throw new Error(`Missing kernel headers: ${path}`);
		}
	}
	return headers;
};

// Headers stay outside the build context, so the image is shared
const packCrcGate = async (service, tmp) => {
	const headers = stagedHeaders(service);
	const stage = join(tmp, 'stage');

	cpSync(CRC_GATE_ASSETS, join(stage, 'context'), { recursive: true });
	mkdirSync(join(stage, 'in'));
	copyFileSync(headers.base, join(stage, 'in', 'base.tar.gz'));
	copyFileSync(headers.ext, join(stage, 'in', 'ext.tar.gz'));

	const tarball = join(tmp, 'crc-gate.tar');
	await execFileAsync('tar', ['-cf', tarball, '-C', stage, '.']);
	return tarball;
};

const parseMeasure = (text) => {
	const env = keyValues(text);
	return ['MOVED_TOTAL', 'MOVED_REFERENCED'].reduce((acc, key) => {
		if (!/^[0-9]+$/.test(env[key] || '')) {
			throw new Error(`measure.env has no count for ${key}: ${text}`);
		}
		acc[key] = Number(env[key]);
		return acc;
	}, {});
};

const cleanupCrcGate = async (that) => {
	await host(
		that,
		`balena-engine rmi -f ${CRC_GATE_IMAGE} || true ; rm -rf ${CRC_GATE_DIR}`,
	);
	that.suite.context.set({ crcGate: null });
};

/**
 * Builds the crc-gate modules on the DUT against the staged headers of
 * service. Resolves to the DUT paths of control.ko, subject.ko and base.ko,
 * and the counts from measure.env. Cached per service for the suite.
 */
const buildCrcGate = async (that, test, service) => {
	const cache = that.suite.context.get().crcGate;
	if (cache != null && cache[service] != null) {
		return cache[service];
	}
	if (cache == null) {
		that.suite.context.set({ crcGate: {} });
		that.suite.teardown.register(() => {
			return cleanupCrcGate(that);
		});
	}

	const dir = `${CRC_GATE_DIR}/${service}`;
	const tmp = mkdtempSync(join(tmpdir(), 'crc-gate-'));
	try {
		const tarball = await packCrcGate(service, tmp);
		await mustRun(that, `rm -rf ${dir} && mkdir -p ${dir}`);
		await sendFile(
			that,
			test,
			tarball,
			`${dir}/`,
			`the crc-gate context for ${service}`,
		);
	} finally {
		rmSync(tmp, { recursive: true, force: true });
	}

	await mustRun(
		that,
		`tar -xf ${dir}/crc-gate.tar -C ${dir} && rm ${dir}/crc-gate.tar` +
			` && mkdir -p ${dir}/out`,
	);
	await mustRun(
		that,
		`balena-engine build -t ${CRC_GATE_IMAGE} ${dir}/context`,
	);
	await mustRun(
		that,
		`balena-engine run --rm -v ${dir}/in:/in:ro -v ${dir}/out:/out` +
			` ${CRC_GATE_IMAGE}`,
	);

	const built = {
		control: `${dir}/out/control.ko`,
		subject: `${dir}/out/subject.ko`,
		base: `${dir}/out/base.ko`,
		measure: parseMeasure(await mustRun(that, `cat ${dir}/out/measure.env`)),
	};
	that.suite.context.set({ crcGate: { [service]: built } });
	return built;
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

const loadedModules = async (that) => {
	return host(that, "lsmod | awk 'NR > 1 {print $1}' | LC_ALL=C sort");
};

// Absent on kernels without module signing
const sigEnforced = async (that) => {
	return (
		(await host(
			that,
			'cat /sys/module/module/parameters/sig_enforce 2>/dev/null || true',
		)) === 'Y'
	);
};

const unloadCrcGate = async (that, test) => {
	test.is(
		await exitCode(that, 'rmmod crc_gate'),
		'0',
		'Should unload crc_gate',
	);
};

const probeCrcGate = async (that, test, ko) => {
	test.not(await cmdlineAbi(that), '', 'Should be running the override kernel');
	// Without modversions nothing checks CRCs: a defect, not a skip
	test.ok(
		/\bmodversions\b/.test(
			await host(that, `modinfo -F vermagic ${ko.control} || true`),
		),
		'The kernel should check symbol CRCs',
	);

	if (await sigEnforced(that)) {
		test.comment('Module signatures are enforced; skipping the CRC gate loads');
		return;
	}

	await host(that, 'dmesg -C');
	const control = await exitCode(that, `insmod ${ko.control}`);
	test.is(
		control,
		'0',
		'A module built against the running kernel should load',
	);
	if (control === '0') {
		await unloadCrcGate(that, test);
	}

	await host(that, 'dmesg -C');
	const subject = await exitCode(that, `insmod ${ko.subject}`);
	test.not(subject, '0', 'A module with a wrong symbol CRC should be refused');
	// insmod stderr only says "Invalid module format"
	test.ok(
		/disagrees about version of symbol _printk/.test(await host(that, 'dmesg')),
		'The refusal should name the mismatched symbol',
	);
	if (subject === '0') {
		await unloadCrcGate(that, test);
	}
};

// Records what a customer module built today does
const measureBaseModule = async (that, test, ko) => {
	if (await sigEnforced(that)) {
		test.comment(
			'Module signatures are enforced; skipping the base module measurement',
		);
		return;
	}

	await host(that, 'dmesg -C');
	const code = await exitCode(that, `insmod ${ko.base}`);
	const refused = (await host(that, 'dmesg')).match(
		/disagrees about version of symbol (\S+)/,
	);
	const symbol = refused != null ? refused[1] : 'none';
	const { MOVED_TOTAL, MOVED_REFERENCED } = ko.measure;

	const summary =
		`base.ko: insmod exit ${code}, refused symbol ${symbol},` +
		` moved CRCs ${MOVED_TOTAL}, moved CRCs referenced ${MOVED_REFERENCED}`;
	test.comment(summary);
	await that.worker.archiveLogs(that.id, that.link, `echo '${summary}'`);

	if (code === '0') {
		await unloadCrcGate(that, test);
		test.is(
			MOVED_REFERENCED,
			0,
			'A base-built module that loads should reference no moved CRC',
		);
	}
};

const MODULES_MANIFEST = '/tmp/crc-gate-manifest';

// Manifest lines match find output from the modules tree root
const extensionTree = async (that, id, rel) => {
	// The extension ships /usr/lib/modules; tar paths have no leading slash
	const program = [
		'{ p = "/" $0; i = index(p, d) } !i { next }',
		'{ r = substr(p, i + length(d)) }',
		'r ~ /\\.ko[^\\/]*$/ { print "./" r | s }',
		'r == "modules.symbols" { print $0 }',
		'END { close(s) }',
	].join(' ');
	const listed = await mustRun(
		that,
		`: > ${MODULES_MANIFEST} && balena-engine export ${id} | tar -tf - |` +
			` awk -v d='/modules/${rel}/' -v s='LC_ALL=C sort > ${MODULES_MANIFEST}'` +
			` '${program}'`,
	);
	// mustRun merges stderr, so pick the member by name
	const member =
		listed
			.split('\n')
			.filter((line) => {
				return line.endsWith(`/modules/${rel}/modules.symbols`);
			})
			.pop() || '';

	return {
		manifest: MODULES_MANIFEST,
		moduleCount: await mustRun(that, `wc -l < ${MODULES_MANIFEST}`),
		symbolsSha:
			member === ''
				? ''
				: await mustRun(
						that,
						`balena-engine export ${id} | tar -xOf - '${member}'` +
							" | sha256sum | cut -d' ' -f1",
					),
	};
};

// modules.symbols alone differs between the two layers
const probeModulesTree = async (that, test, service) => {
	const rel = await host(that, 'uname -r');
	// A subshell keeps a failed cd from tripping host retries
	const deviceModules = `(cd /lib/modules/${rel} && find . -name '*.ko*')`;

	try {
		const expected = await extensionTree(
			that,
			await overlayContainer(that, service),
			rel,
		);

		test.ok(
			Number(expected.moduleCount) > 0,
			'The extension manifest should list modules',
		);

		test.is(
			await host(that, `${deviceModules} | wc -l`),
			expected.moduleCount,
			'Should carry the extension module set',
		);

		test.is(
			await host(
				that,
				`sha256sum /lib/modules/${rel}/modules.symbols | cut -d' ' -f1`,
			),
			expected.symbolsSha,
			'modules.symbols should be the extension copy',
		);

		// Unsorted input makes comm report false leaks
		test.is(
			await host(
				that,
				`${deviceModules} | LC_ALL=C sort |` +
					` LC_ALL=C comm -13 ${expected.manifest} - | wc -l`,
			),
			'0',
			'No base-only module should be reachable',
		);
	} finally {
		await host(that, `rm -f ${MODULES_MANIFEST}`);
	}
};

const probeKernelOverride = async (that, test, service) => {
	const before = await loadedModules(that);

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

	// Reverse of load order; modprobe -r drops dependencies too
	for (const mod of ['nfs', 'hfs']) {
		test.is(
			await exitCode(that, `modprobe -r ${mod}`),
			'0',
			`Should unload ${mod}`,
		);
	}

	// Before the build, which needs the staged headers
	await probeModulesTree(that, test, service);

	const ko = await buildCrcGate(that, test, service);
	await probeCrcGate(that, test, ko);
	await measureBaseModule(that, test, ko);

	// Last, so it also proves crc_gate was unloaded
	test.is(
		await loadedModules(that),
		before,
		'Should leave the loaded module set unchanged',
	);
};

const PROBES = {
	tracing: probeTracing,
	ebpf: probeEbpf,
};

// Override claims assert the running kernel before this gate
const probe = async (that, test, service) => {
	const entry = PROBES[service];
	if (entry != null) {
		await entry(that, test);
	}

	const abi = kernelAbiId(await overlayLabels(that, service));
	if (abi === '') {
		if (entry == null) {
			test.comment(`No functional probe for ${service}`);
		}
		return;
	}

	const running = await cmdlineAbi(that);
	if (running !== abi) {
		test.comment(
			`Skipping the ${service} kernel override probe: running ABI "${running}", label "${abi}"`,
		);
		return;
	}

	await probeKernelOverride(that, test, service);
};

module.exports = {
	activateLocal,
	activeSlot,
	artifacts,
	auditLine,
	bootEnv,
	bootId,
	buildCrcGate,
	captureKernelLog,
	cleanupCrcGate,
	cmdlineAbi,
	containerName,
	exitCode,
	host,
	imageLabels,
	inventory,
	journalCount,
	kernelAbiId,
	loadImage,
	osVersionId,
	osVersionMatches,
	overlayContainer,
	overlayLabels,
	overlays,
	placement,
	previousBootId,
	probe,
	rejectionRecord,
	removeImage,
	run,
	runningSlot,
	heliosVersion,
	runtimeRegistered,
	sendArtifacts,
	unitExists,
	unitResult,
	withdrawLocal,
};
