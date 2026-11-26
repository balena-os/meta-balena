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
	rmSync,
} = require('fs');
const { tmpdir } = require('os');
const { join } = require('path');
const { promisify } = require('util');

const execFileAsync = promisify(execFile);

// Leviathan uploads one suite directory.
// Keep this file identical in cloud and hup.

// Staged by CI for the crc-gate build
const HEADERS_DIR = join(__dirname, '..', 'headers');
const CRC_GATE_ASSETS = join(__dirname, '..', 'assets', 'crc-gate');

const CRC_GATE_DIR = '/mnt/data/resin-data/crc-gate';
const CRC_GATE_IMAGE = 'crc-gate';

const CLASS_LABEL = 'io.balena.image.class';
const KERNEL_ABI_LABEL = 'io.balena.image.kernel-abi-id';
const OS_VERSION_LABEL = 'io.balena.image.os-version';

// Sourcing the config vars and the find must share one shell
const BOOTENV_LOCATE =
	'. /usr/sbin/balena-config-vars ; ' +
	'find -L "${BALENA_NONENC_BOOT_MOUNTPOINT}" ' +
	'\\( -name bootenv -o -name grubenv \\) | head -1';

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

// A reason closes the gate and skips the node
const opened = (test, reason) => {
	if (reason !== null) {
		test.plan(0, reason);
		return false;
	}
	return true;
};

// The local link stays up when the VPN stops
const host = async (that, command) => {
	if (that.worker != null && that.link != null) {
		return that.worker.executeCommandInHostOS(command, that.link);
	}
	return that.cloud.executeCommandInHostOS(command, that.balena.uuid);
};

// The trailing exit code prevents a retry
const run = async (that, command) => {
	const out = (
		// A newline separates the output from the code
		await host(that, `${command} 2>&1 ; printf '\\n%s' $?`)
	).trim();
	const lines = out.split('\n');
	const code = lines.pop().trim();
	return { code: code, output: lines.join('\n').trim() };
};

// The error includes the output of the command
const mustRun = async (that, command) => {
	const result = await run(that, `{ ${command} ; }`);
	if (result.code !== '0') {
		throw new Error(`"${command}" exited ${result.code}: ${result.output}`);
	}
	return result.output;
};

// Returns only the exit code
const exitCode = async (that, command) => {
	return host(that, `{ ${command} ; } > /dev/null 2>&1 ; echo $?`);
};

// Only the label identifies an overlay container
const overlays = async (that) => {
	const out = await host(
		that,
		`balena-engine ps -a --filter "label=${CLASS_LABEL}=overlay"` +
			' --format "{{.Names}}\t{{.Status}}" || true',
	);

	return lines(out).map((line) => {
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

const assertPlaced = async (that, test, gate, when) => {
	const placed = await placement(that);
	for (const service of gate.services) {
		test.ok(
			placed.includes(service),
			`Should place the ${service} overlay in the root filesystem ${when}`,
		);
	}
};

// IDs show a container that was created again
const inventory = async (that) => {
	const list = async (command) => {
		const out = await host(
			that,
			`${command} --filter "label=${CLASS_LABEL}=overlay" || true`,
		);
		return lines(out).sort();
	};

	return {
		containers: await list('balena-engine ps -aq --no-trunc'),
		images: await list('balena-engine images -q --no-trunc'),
	};
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
		// stderr is in the output, so show it
		throw new Error(
			`Could not parse the labels of ${ref}: ${inspected.output}`,
		);
	}

	return labels === null ? {} : labels;
};

const imageLabels = async (that, image) => {
	return inspectLabels(that, 'image', image);
};

// Both activateLocal and helios label the container this way
const overlayContainer = async (that, service) => {
	const ids = lines(
		await mustRun(
			that,
			'balena-engine ps -aq --no-trunc' +
				` --filter label=io.balena.service-name=${service}` +
				` --filter label=${CLASS_LABEL}=overlay`,
		),
	);

	if (ids.length !== 1) {
		throw new Error(
			`Expected one overlay container for ${service}, found ${ids.length}`,
		);
	}

	return ids[0];
};

// The container config has the image labels
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

// Slots A and B follow the rootfs label
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

const cmdlineAbi = async (that) => {
	return host(
		that,
		'grep -o "balena_kernel_abi=[^ ]*" /proc/cmdline | cut -d= -f2 || true',
	);
};

const rejectionRecord = async (that) => {
	return host(that, 'cat /mnt/state/override-rejected 2>/dev/null || true');
};

// Holds the last HUP rejection, which nothing removes
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

const unitExists = async (that, unit) => {
	return (await exitCode(that, `systemctl cat ${unit}`)) === '0';
};

// Evidence for each boot, not an assertion
const captureKernelLog = async (that) => {
	await that.worker.archiveLogs(
		that.id,
		that.link,
		'dmesg --level=emerg,alert,crit,err,warn || true',
	);
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

// The image has no headers, so services share it
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
	// worker.sendFile has no route over the cloud gateway
	if (that.worker == null || that.link == null) {
		throw new Error(
			`Cannot build crc-gate for ${service}: it needs the worker's local link`,
		);
	}

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
	// No modversions means no CRC check: a defect
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
		/disagrees about version of symbol _?printk\b/.test(await host(that, 'dmesg')),
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

// Manifest lines match find output from the tree root
const extensionTree = async (that, id, rel) => {
	// tar paths of /usr/lib/modules have no leading slash
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
	// A subshell stops a failed cd causing retries
	const deviceModules = `(cd /lib/modules/${rel} && find . -name '*.ko*')`;

	test.is(
		await host(
			that,
			`findmnt --noheadings --output SOURCE "$(readlink -f /lib/modules/${rel})" | wc -l`,
		),
		'1',
		'Should bind one mount over the modules tree',
	);

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

	// Reverse load order. modprobe -r also removes dependencies.
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

// Cloud runs ungated: the activation reboot boots the override
const probe = async (that, test, service, gated = false) => {
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

	const running = gated ? await cmdlineAbi(that) : abi;
	if (running !== abi) {
		test.comment(
			`Skipping the ${service} kernel override probe: running ABI "${running}", label "${abi}"`,
		);
		return;
	}

	await probeKernelOverride(that, test, service);
};

// Try the image labels first, then the binary
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
	// "helios 0.28.2" or bare "0.28.2"
	const match = reported.match(/([0-9]+\.[0-9]+\.[0-9]+[^\s]*)/);
	return match == null ? '' : match[1];
};

module.exports = {
	assertPlaced,
	atLeast,
	auditLine,
	bootEnv,
	bootId,
	captureKernelLog,
	cmdlineAbi,
	exitCode,
	heliosVersion,
	host,
	imageLabels,
	inventory,
	kernelAbiId,
	lines,
	opened,
	osVersionId,
	overlayLabels,
	overlays,
	placement,
	probe,
	rejectionRecord,
	run,
	runningSlot,
	runtimeRegistered,
	sendFile,
	unitExists,
	CLASS_LABEL,
	OS_VERSION_LABEL,
};
