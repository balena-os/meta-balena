'use strict';

const fse = require('fs-extra');
const securebootEfiVarPath = '/sys/firmware/efi/efivars/SecureBoot-*';

class secureBoot {
	constructor(test, worker, suite, imagePath, module = {"name": "", "headersVersion": ""}) {
		this.test = test;
		this.worker = worker;
		this.link = suite.context.get().link;
		this.imagePath = imagePath;
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
			Promise.all(
				[
					{ pattern: '/^\\/mnt\\/boot$/', name: 'Boot partition' },
					{ pattern: '/^\\/mnt\\/sysroot\\/active$/', name: 'Root partition' },
					{ pattern: '/^\\/mnt\\/state$/', name: 'State partition' },
					{ pattern: '/^\\/mnt\\/data$/', name: 'Data partition' },
				].map(args => this.test.resolveMatch(
						this.worker.executeCommandInHostOS(
							[
								'lsblk', '-nlo', 'MOUNTPOINT,TYPE',
								'|', 'awk', `'$1 ~ ${args.pattern} { print $2 }'`
							],
							this.link,
						),
						/crypt/,
						`${args.name} is encrypted`,
					)
				)
			);
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
			await fse.copy(srcDir, this.tmpDir);
			let data = await fse.readFile(`${this.tmpDir}/docker-compose.yml`, 'utf-8')
			const result = data.replace(/os_version:\s*\S+/, `os_version: ${this.module.headersVersion}`);
			await fse.writeFile( `${this.tmpDir}/docker-compose.yaml`, result, 'utf-8')
			this.test.comment(`Using kernel headers version ${this.module.headersVersion}`)
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

	async testBootloaderIntegrity() {
		throw new Error("Method testBootloaderIntegrity() must be implemented");
	}

	async testBootloaderConfigIntegrity() {
		throw new Error("Method testBootloaderConfigIntegrity() must be implemented");
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
			).then(output => { return output === 'true'});
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

	async waitForFailedBoot(){
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
		// the CM4 takes a while to get into a state where we can SSH into it anyway after powering on - so we want to try a good number of times.
		try {
			await this.worker.executeCommandInHostOS('echo -n pass',this.link, { max_tries: 20, interval: 1000 });
			// if we manage to SSH into the DUT, then something has gone wrong - so throw an error which will fail the test
			throw new Error(`DUT was still reachable over SSH`)
		} catch (e){
			// we want / are expecting a failure here, so if the SSH fails after the specified number of retries, we want to return
			console.log(`DUT was not reachable over SSH`)
			return
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
	}
}

module.exports = {
	title: 'secure boot tests',
	tests: [
		{
			title: 'check UEFI secure boot',
			run: async function(test) {
				const impl = new testSecureBoot(new uefiSecureBoot(test,
					this.worker,
					this.suite, this.os.image.path,
					{"name": "pcan_netdev", "headersVersion": "2.108.6"}));
				await impl.run(test);
			},
		},
		{
			title: 'check RPI secure boot',
			run: async function(test) {
				const impl = new testSecureBoot(new rpiSecureBoot(test,
					this.worker,
					this.suite, this.os.image.path,
					{"name": "", "headersVersion": "4.0.16"}));
				await impl.run(test);
			},
		},
	]
}
