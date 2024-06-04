'use strict';

const fs = require('fs');
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

		await this.worker.addSSHKey(this.sshKeyPath);
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
			fs.readFile(`${this.tmpDir}/docker-compose.yml`, 'utf-8', (err,data) => {
				if (err) {
					throw new Error(`Unable to find ${this.tmpDir}/docker-compose.yml`)
				}
				const result = data.replace(/os_version:\s*\S+/, `os_version: ${this.module.headersVersion}`);
				fs.writeFile( `${this.tmpDir}/docker-compose.yaml`, result, 'utf-8', (err) => {
					if (err) {
						throw new Error(`Unable to write ${this.tmpDir}/docker-compose.yml`)
					}
				})
			})
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
	]
}
