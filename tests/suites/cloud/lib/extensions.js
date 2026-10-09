/*
 * Copyright 2026 balena
 *
 * @license Apache-2.0
 */

'use strict';

const request = require('request-promise');

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
const { execFile } = require('child_process');
const {
	copyFileSync,
	cpSync,
	existsSync,
	mkdirSync,
	mkdtempSync,
	readFileSync,
	rmSync,
} = require('fs');
const { tmpdir } = require('os');
const { join } = require('path');
const { promisify } = require('util');

const execFileAsync = promisify(execFile);

/*
 * A workflow env var cannot reach a test: the core receives only
 * FLASHER_SECUREBOOT, and it builds the suite options from a fixed list of
 * config keys. CI therefore writes this file into the suite directory, which is
 * uploaded whole, the same route the hup extension archives take. process.env
 * is the fallback for manual runs.
 */
const STAGED_CONFIG = join(__dirname, '..', 'hostapp.json');

// Staged by CI like STAGED_CONFIG, for the crc-gate build
const HEADERS_DIR = join(__dirname, '..', 'headers');
const CRC_GATE_ASSETS = join(__dirname, '..', 'assets', 'crc-gate');

const CRC_GATE_DIR = '/mnt/data/resin-data/crc-gate';
const CRC_GATE_IMAGE = 'crc-gate';

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
 * The API names the roles of "application1 activates profile name on
 * application2" after the verb, not the terms (balena.sbvr:1001).
 */
const PROFILE_ACTIVATOR = 'application';
const PROFILE_TARGET = 'on__application';
const PROFILE_NAME = 'activates__profile_name';

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

const imageLabels = async (that, image) => {
	return inspectLabels(that, 'image', image);
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
/* Kernel command line                                                         */
/* -------------------------------------------------------------------------- */

/*
 * A one-line file the first stage passes to the kernel. A copy restores the
 * exact original. vfat keeps no modes, so a plain cp.
 */
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
			`sync -f ${path} ; true`,
	};
};

/*
 * kexec passes the stage 2 command line to the main kernel, so on a balena
 * bootloader both kernels see an argument added here. Add a hook per boot
 * file; the first whose file exists applies.
 */
const CMDLINE_HOOKS = [cmdlineFile('/mnt/boot/cmdline.txt')];

/**
 * The hook that adds kernel arguments on this device, or null when none
 * applies. add and restore resolve to the command's exit code, and each
 * takes effect on the next boot.
 */
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

/* -------------------------------------------------------------------------- */
/* Module build                                                                */
/* -------------------------------------------------------------------------- */

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

// Ungated: the activation reboot must boot the override
const probe = async (that, test, service) => {
	const entry = PROBES[service];
	if (entry != null) {
		await entry(that, test);
	}

	if (kernelAbiId(await overlayLabels(that, service)) === '') {
		if (entry == null) {
			test.comment(`No functional probe for ${service}`);
		}
		return;
	}

	await probeKernelOverride(that, test, service);
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
		body: { should_be_managed_by__release: releaseId },
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
				'should_be_managed_by__release',
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

	return apiRequest({
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
	buildCrcGate,
	captureKernelLog,
	cleanupCrcGate,
	cmdlineAbi,
	cmdlineHas,
	cmdlineHook,
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
	overlayContainer,
	overlayLabels,
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
