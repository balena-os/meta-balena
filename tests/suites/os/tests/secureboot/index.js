'use strict';

const fse = require('fs-extra');
const securebootEfiVarPath = '/sys/firmware/efi/efivars/SecureBoot-*';
const qmp = require("@balena/node-qmp");
const path = require('path');

const retry = (fn, delay_ms=250, retries=10 * 4, err) => (
	!retries
	? Promise.reject(`Exhausted retries: ${err}`)
	: fn().catch(e => setTimeout(
			() => retry(fn, delay_ms, (retries - 1), e),
			delay_ms
		)
	)
);

class secureBoot {
	constructor(test, worker, suite, imagePath, kernelHeadersPath,  module = {"name": "", "headersVersion": ""}) {
		this.test = test;
		this.worker = worker;
		this.suite = suite;
		this.workerType = suite.context.get().workerContract.workerType;
		this.link = suite.context.get().link;
		this.imagePath = imagePath;
		this.kernelHeadersPath = kernelHeadersPath;
		this.sshKeyPath = suite.context.get().sshKeyPath;
		this.utils = suite.context.get().utils;
		this.module = module;
		this.tmpDir = suite.options.tmpdir;
	}

	async resetDUT() {
		await this.worker.off();
		await this.worker.flash(this.imagePath);
		await this.worker.on();
	}

	async waitForSerialOutput(pattern, slice=0, retries=60, delay=1000) {
		await this.utils.waitUntil(
			async () => this.worker.fetchSerial().then(
				serialLogs => {
					return serialLogs.split('\n')
					.slice(slice)
					.join('\n')
					.match(pattern)
				}), false, retries, delay
		);
	}

	async isSecureBootSupported() {
		throw new Error("Method isSecureBootSupported() must be implemented");
	}

	async isSecureBootEnabled() {
		throw new Error("Method isSecureBootEnabled() must be implemented");
	}

	async testFullDiskEncryption() {
		await Promise.all(
			[
				{ path: '/dev/disk/by-state/resin-boot', name: 'Boot partition' },
				{ path: '/dev/disk/by-state/resin-rootA', name: 'RootA partition' },
				{ path: '/dev/disk/by-state/resin-rootB', name: 'RootB partition' },
				{ path: '/dev/disk/by-state/resin-state', name: 'State partition' },
				{ path: '/dev/disk/by-state/resin-data', name: 'Data partition' },
			].map(args => {
				this.test.resolveMatch(
					this.worker.executeCommandInHostOS(
						`. /usr/libexec/os-helpers-fs; is_part_encrypted ${args.path} && echo pass`,
						this.link,
					),
					/pass/,
					`${args.name} is encrypted`,
				)
			})
		);

		if (!this.qmp) {
			this.test.comment('QMP is unavailable, skipping encryption tampering test');
			return
		}

		const label = "resin-data";
		await this.worker.executeCommandInHostOS(
			['while systemctl is-active balena balena-supervisor systemd-journald;',
					 'do systemctl stop balena balena-supervisor systemd-journald; done',
				 `&& while umount /dev/disk/by-label/${label}; do : ; done`,
				 `&& cryptsetup luksClose /dev/disk/by-label/${label}`,
				 `&& mkfs.ext4 -L ${label} -F /dev/disk/by-partlabel/${label}`,
			],
			this.link,
		).then(() =>
			this.test.resolves(() => {
				return Promise.all([
					this.worker.executeCommandInHostOS('reboot', this.link),
					this.waitForFailedBoot(),
				]);
			},
			'Kernel will not boot with tampered encrypted partitions',
			)
		);

		return this.resetDUT();
	}

	async testModuleVerification() {
		if (this.module.name.length != 0) {
			await this.test.resolves(
				this.worker.executeCommandInHostOS(`modprobe ${this.module.name}`, this.link),
				`Module ${this.module.name} with valid signature loads`,
			);
		} else {
			this.test.comment("No module with valid signature specified - skipping")
		}

		if (this.module.headersVersion.length != 0) {
			const srcDir = `${__dirname}/kernel-module-build/`
			const headersArchivePath = this.kernelHeadersPath;

			try {
				const exists = await fse.pathExists(headersArchivePath);
				await fse.copy(srcDir, this.tmpDir);
				if (exists) {
					await fse.copy(headersArchivePath, `${this.tmpDir}/module/${path.basename(headersArchivePath)}`);
					this.test.comment('Using provided kernel headers');
				} else {
					const dockerComposePath = `${this.tmpDir}/docker-compose.yml`;
					const data = await fse.readFile(dockerComposePath, 'utf-8');
					const updatedData = data.replace(/OS_VERSION:\s*\S+/, `OS_VERSION: ${this.module.headersVersion}`);
					await fse.writeFile(dockerComposePath, updatedData, 'utf-8');
					this.test.comment(`Using kernel headers version ${this.module.headersVersion}`);
				}
			} catch (err) {
				console.error(err);
				return;
			}
		}

		await this.worker.pushContainerToDUT(
			this.link,
			`${this.tmpDir}`,
			'load',
		);

		return this.test.resolveMatch(
			this.worker.executeCommandInHostOS(
				'balena logs $(balena ps -aqf NAME=load)',
				this.link,
			),
			/Key was rejected by service/,
			'Unsigned module does not load',
		);
	}

	async waitForFailedBoot() {
		// confirm that eth link is high
		// we don't know what the ethernet interface connecting worker to DUT is, so first find that, using the autokit WIRED_IFACE var
		let iface = await this.worker.executeCommandInWorker(`env | grep WIRED | awk -F'=' '{print $2}'`);

		console.log(`Watching interface: ${iface}`)
		// confirm that the link is high - confirming that the board is on
		await this.utils.waitUntil(async() => {
			console.log('Confirming eth link is present...')
			let ethLink = await this.worker.executeCommandInWorker(`cat /sys/class/net/${iface}/carrier`);
			console.log(`Eth link is: ${ethLink}`)
			return ethLink === '1';
		})

		// SSH access shouldn't be possible - as the device shouldn't be booting?
		// Devices take a while to get into a state where we can SSH into after powering on - so we want to try a good number of times.
		try {
			await this.worker.executeCommandInHostOS('echo -n pass',this.link, { max_tries: 20, interval: 1000 });
			// if we manage to SSH into the DUT, then something has gone wrong - so throw an error which will fail the test
		} catch (e) {
			// we want / are expecting a failure here, so if the SSH fails after the specified number of retries, we want to return
			console.log(`DUT was not reachable over SSH`)
			return
		}

		throw new Error(`DUT was still reachable over SSH`)
	}

	async testBootloaderIntegrity() {
		throw new Error("Method testBootloaderIntegrity() must be implemented");
	}

	async testBootloaderConfigIntegrity() {
		throw new Error("Method testBootloaderConfigIntegrity() must be implemented");
	}

	async teardown()
	{
	}
}

class uefiSecureBoot extends secureBoot {
	async isSecureBootSupported() {
			return this.worker.executeCommandInHostOS(
				['ls', securebootEfiVarPath, '&>/dev/null',
					'&&', 'echo', 'true',
					'||', 'echo', 'false'
				],
				this.link,
			).then(output => { return output === 'true' && this.workerType !== 'qemu' });
	}

	async isSecureBootEnabled() {
			// https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot#Checking_Secure_Boot_status
			return this.worker.executeCommandInHostOS(
					[
						'od', '--address-radix=n', '--format=u1', securebootEfiVarPath,
							'|', 'tr', '-s', "' '",
							'|', 'cut', "-d' '", '-f6'
					],
					this.link,
			).then(output => output === '1' );
	}

	async testBootloaderIntegrity() {
		return this.worker.executeCommandInHostOS(
			['balena', 'run', '--rm', '-v', '/mnt:/mnt', 'alpine', '/bin/sh', '-c',
				'"apk add --update --no-cache binutils && strip /mnt/boot/EFI/BOOT/bootx64.efi"'],
			this.link,
		).then(() => this.worker.executeCommandInHostOS('reboot', this.link)
		).then(() => this.test.resolves(
			this.waitForSerialOutput(/bootx64.efi: Access Denied/),
			'Firmware will not load bootloader that fails verification',
		)
		).then( () => this.resetDUT() );
	};

	async testBootloaderConfigIntegrity() {
		return this.worker.executeCommandInHostOS(
			['sed', '-i', 's/lockdown=integrity//', '/mnt/efi/EFI/BOOT/grub.cfg'],
			this.link
		).then(() => this.worker.executeCommandInHostOS('reboot', this.link)
		).then(() => this.test.resolves(
			/* The below pattern is the expected output when the config file
			 * fails the signature check and the fallback console is not enabled.
			 *
			 * This sequence of ANSI escape codes decodes as:
			 *
			 *	ESC[0m - reset all modes
			 *	ESC[37m - white foreground
			 *	ESC[40m - black background
			 *
			 *	https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
			 *
			 * Otherwise, the output finishes the above background color escape
			 * sequence, clears the screen, and shows 'loading Boot0003
			 * "balenaOS"'
			 */

			this.waitForSerialOutput(/\x1B\[0m\x1B\[37m\x1B\[40m$/, 3), // eslint-disable-line no-control-regex
			'Bootloader will not load configuration that fails signature verification',
			{ todo: 'This needs reworked for GRUB 2.12' },
		)
		).then( () => this.resetDUT() );
	};
}

class qemuSecureBoot extends uefiSecureBoot {
	constructor(...args) {
		super(...args);
		this.qmpSock = '/run/qemu/qmp.sock';
		this.qmpClient = new qmp.Client();
		this.qmp = false;
		if (fse.existsSync(this.qmpSock)) {
			this.qmp = true;
			this.setupQMP();
		}
	}

	async qmpConnect() {
		return retry(() => this.qmpClient.connect(this.qmpSock)
		).then(() => console.log("Connected to QMP socket")
		).catch(e => {
			console.log("Unable to connect to QMP socket");
			throw e;
		});
	}

	async setupQMP() {
		if (this.qmp) {
			this.qmpClient.once('disconnect', this.qmpConnect);
			return this.qmpConnect();
		}
	}

	async teardownQMP() {
		this.qmpClient.removeAllListeners();
	}

	async teardown() {
		this.teardownQMP();
	}

	async resetDUT() {
		// flashing takes longer than we expect a QMP connection to take, so
		// temporarily teardown the connection until it's finished
		await this.teardownQMP();
		await super.resetDUT();
		await this.setupQMP();
	}

	async isSecureBootSupported() {
		return this.workerType === 'qemu'
	}

	async waitForFailedBoot() {
		return new Promise((resolve, reject) => {
			/* Wait for the machine to reset, then resolve once the machine resets
			 * again within the timeout (boot failed)
			 */
			this.qmpClient.once('reset', () => {
				setTimeout(reject, 10 * 1000);
				this.qmpClient.once('reset', resolve);
			});
		});
	}
}

class rpiSecureBoot extends secureBoot {
	async isSecureBootSupported() {
		let out = await this.worker.executeCommandInHostOS(
			'if command -v vcgencmd > /dev/null; then echo "pass"; fi',
			this.link
		)
		return out === 'pass';
	}

	async readPrivateKey() {
		let reg = await this.worker.executeCommandInHostOS(
			['vcmailbox', '0x00030081', '40 40 0 8 0 0 0 0 0 0 0 0'],
			this.link
		)
		const key = reg
			.replace(/0x/g, '') // remove 0x prefix
			.trim()							// remove extra spaces
			.split(/\s+/)				// split by whitespace
			.slice(7, 15)				// take elements 8 to 15
			.join('');          // concatenate
		return key;
	}

	async readOTPReg(reg) {
		let out = await this.worker.executeCommandInHostOS(
			['vcgencmd', 'otp_dump', '2>/dev/null'],
			this.link
		)
		for ( const line of out.split('\n')) {
			if (line.startsWith(reg)) {
				return line.split(':')[1].trim();
			}
		}
	}

	async checkRSAkey() {
		for (let reg = 47; reg <= 54; reg++) {
			let out = await this.readOTPReg(reg)
			if ( out && out != "00000000") {
				return true
			}
		}
		return false
	}

	async isSecureBootEnabled() {
		// OTP is programmed with customer key digest and private key
		if ( await this.checkRSAkey() ) {
			const key = await this.readPrivateKey();
			if ( key.replace(/0/g, '').trim().length > 0 ) {
				return true;
			}
		}
	}

	async testBootloaderIntegrity() {
		/* Modify boot.sig to fail authentication */
		await this.worker.executeCommandInHostOS(
			"sed -i -e '1s/^.\\(.*\\)$/\\1/' /mnt/rpi/boot.sig",
			this.link
		)
		await this.worker.executeCommandInHostOS('reboot', this.link)
	    await this.test.resolves(
			this.waitForFailedBoot(),
			'Bootloader will not load configuration that fails signature verification',
		)
		await this.resetDUT();
	}

	async testBootloaderConfigIntegrity() {
		/* Modify config.txt inside boot.img */
		await this.worker.executeCommandInHostOS(
			"tmpDir=$(mktemp -d) && mount -o loop /mnt/rpi/boot.img ${tmpDir} && sed -i 's/$/#comment/' ${tmpDir}/config.txt && umount ${tmpDir} && rm -rf ${tmpDir}",
			this.link
		)
		await this.worker.executeCommandInHostOS('reboot', this.link)
		await this.test.resolves(
			this.waitForFailedBoot(),
			'Bootloader will not load configuration that fails signature verification',
		)
		await this.resetDUT();
	}
}

const CSF_HEADER = "d1002040"
const CSF_HEADER_BAD = "d1002041"

class imxSecureBoot extends secureBoot {
	async isSecureBootSupported() {
		let out = await this.worker.executeCommandInHostOS(
			'if command -v imx-otp-tool > /dev/null; then echo "pass"; fi',
			this.link
		)
		return out === 'pass';
	}

	async isSecureBootEnabled() {
		let out = await this.worker.executeCommandInHostOS(
			'if imx-otp-tool --quiet is-secured; then echo "pass"; fi',
			this.link
		)
		return out === 'pass';
	}

	async replaceBinaryPattern(pathPattern, pattern=CSF_HEADER, replacement=CSF_HEADER_BAD) {
		await this.worker.executeCommandInHostOS(
			[`files=$(find $(dirname "${pathPattern}") -name $(basename "${pathPattern}"))`, ';',
				'for f in ${files}; do ',
					'tmpfile=$(mktemp)', ';',
					'is_gzipped=0', ';',
					'if [ "${f#*.}" = "gz" ]; then ',
				  ' decomp_file=$(mktemp)', ';',
				  ' is_gzipped=1', ';',
				  ' gunzip -c "${f}" > "${decomp_file}"', ';',
				  ' orig_file="${f}"', ';',
				  ' f="${decomp_file}"', ';',
				  'fi', ';',
					'xxd -p "${f}" > "${tmpfile}"', ';',
					`sed -i "s/${pattern}/${replacement}/g" "$tmpfile"`, ';',
					'xxd -p -r "${tmpfile}" > "${f}"', ';',
					'if [ "${is_gzipped}" = "1" ]; then ',
				  ' gzip -c "${f}" > "${orig_file}"',';',
				  'fi', ';',
					'rm -f "${tmpfile}" "${decomp_file}"', ';',
				'done', ';',
				`sync -f "$(dirname "${pathPattern}")"`
			],
			this.link
		)
	}

	async testBootloaderIntegrity() {
		const tests = [
			{ name:'Bootloader', path: '/mnt/imx/imx-boot-*.bin-flash_evk', pattern: CSF_HEADER, replacement: CSF_HEADER_BAD },
			{ name:'Balena bootloader', path: '/mnt/imx/Image.gz', pattern: CSF_HEADER, replacement: CSF_HEADER_BAD },
			{ name: 'Device trees', path: '/mnt/imx/*.dtb', pattern: CSF_HEADER, replacement: CSF_HEADER_BAD },
		];

		/* Assert the waitForFailedBoot() to make sure it works */
		await this.test.rejects(
			this.waitForFailedBoot(),
			"waitForFailedBoot() will reject if the device boots successfully",
		)

		for (const args of tests) {
			if ( args.name == 'Bootloader' &&
				( this.suite.deviceType.slug == 'iot-gate-imx8' ||
				  this.suite.deviceType.slug == 'iot-gate-imx8-sb' ) ) {
				// iot-gate-imx8 needs U-Boot for flashing to work
				this.test.comment(`Skipping bootloader integrity test for ${this.suite.deviceType.slug}`);
				continue;
			}

			await this.replaceBinaryPattern(args.path, args.pattern, args.replacement);
			if ( args.name == 'Bootloader' ) {
				// Program the bootloader
				await this.worker.executeCommandInHostOS(
					[
						'tmpdir=$(mktemp -d)', ';',
						'cp /etc/hostapp-update-hooks.d/99-flash-bootloader ${tmpdir}', ';',
						'sed -i "s,resin-boot,mnt/imx,g" ${tmpdir}/99-flash-bootloader', ';',
						'${tmpdir}/99-flash-bootloader', ';'
					],
					this.link
				)
			}
			await this.worker.executeCommandInHostOS('reboot', this.link)
			await this.test.resolves(
				this.waitForFailedBoot(),
				`Device will not boot if ${args.name} fails signature verification`,
			)
			await this.resetDUT();
		}
	}

	async testBootloaderConfigIntegrity() {
		const tests = [
			{ path: '/mnt/imx/resinOS_uEnv.txt', variable: 'extra_os_cmdline', value: 'test' },
			{ path: '/mnt/imx/extra_uEnv.txt', variable: 'extra_os_cmdline', value: 'test' },
			{ path: '/mnt/imx/bootcount.env', variable: 'extra_os_cmdline', value: 'test' },
		];

		for (const args of tests) {
			await this.worker.executeCommandInHostOS(
				`echo '${args.variable}=${args.value}' >> ${args.path} && sync -f $(dirname ${args.path})`,
				this.link
			)
			await this.worker.rebootDut(this.link);
			let cmdline = await this.worker.executeCommandInHostOS(
				'cat /proc/cmdline',
				this.link,
			);
			await this.test.equal(
				cmdline.includes(`${args.value}`),
				false,
				`Kernel command line has not been modified by ${path.basename(args.path)}`,
			)
			await this.worker.executeCommandInHostOS(
				`rm -f ${args.path} && sync -f $(dirname ${args.path})`,
				this.link,
			);
		}

		/* Note that the balena bootloader bootenv cannot be used to
		 * inject kernel command line arguments at the moment */

		await this.resetDUT();
	}
}

class testSecureBoot {
	constructor(impl) {
		this.impl = impl;
	}

	async run(test) {
		if ( await this.impl.isSecureBootSupported() ) {
			if ( await this.impl.isSecureBootEnabled() ) {
				await this.impl.testFullDiskEncryption();
				await this.impl.testModuleVerification();
				await this.impl.testBootloaderIntegrity();
				await this.impl.testBootloaderConfigIntegrity();
			} else {
				test.comment('Secure boot is not enabled');
			}
		} else {
			test.comment('Secure boot is not supported by firmware');
		}

		return this.impl.teardown();
	}
}

module.exports = {
	title: 'secure boot tests',
	tests: [
		{
			title: 'check QEMU secure boot',
			run: async function(test) {
				const impl = new testSecureBoot(new qemuSecureBoot(
					test,
					this.worker,
					this.suite,
					this.os.image.path,
					this.os.kernelHeaders,
					{ name: "pcan_netdev", headersVersion: "2.108.27" },
				));
				return impl.run(test);
			}
		},
		{
			title: 'check UEFI secure boot',
			run: async function(test) {
				const impl = new testSecureBoot(new uefiSecureBoot(test,
					this.worker,
					this.suite, this.os.image.path,
					this.os.kernelHeaders,
					{"name": "pcan_netdev", "headersVersion": "2.108.27"}));
				await impl.run(test);
			},
		},
		{
			title: 'check RPI secure boot',
			run: async function(test) {
				const impl = new testSecureBoot(new rpiSecureBoot(test,
					this.worker,
					this.suite, this.os.image.path,
					this.os.kernelHeaders,
					{"name": "", "headersVersion": "4.0.16"}));
				await impl.run(test);
			},
		},
		{
			title: 'check IMX secure boot',
			run: async function(test) {
				const impl = new testSecureBoot(new imxSecureBoot(test,
					this.worker,
					this.suite, this.os.image.path,
					this.os.kernelHeaders,
					{"name": "", "headersVersion": "6.5.2"}));
				await impl.run(test);
			},
		},
	]
}
