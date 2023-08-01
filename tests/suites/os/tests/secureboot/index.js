'use strict';

module.exports = {
	title: 'secure boot tests',
	tests: [
		{
			title: 'check secure boot',
			run: async function(test) {
				const securebootEfiVarPath = '/sys/firmware/efi/efivars/SecureBoot-*';

				const securebootSupported = await this.worker.executeCommandInHostOS(
					['ls', securebootEfiVarPath, '&>/dev/null',
						'&&', 'echo', 'true',
						'||', 'echo', 'false'
					],
					this.link,
				).then(output => { return output === 'true'});

				// https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot#Checking_Secure_Boot_status
				const securebootEnabled = await this.worker.executeCommandInHostOS(
						[
							'od', '--address-radix=n', '--format=u1', securebootEfiVarPath,
								'|', 'tr', '-s', "' '",
								'|', 'cut', "-d' '", '-f6'
						],
						this.link,
				).then(output => output === '1' );

				// Used after tampering with verified boot files
				const resetWorker = async () => {
					await this.worker.off();
					await this.worker.flash(this.os.image.path);
					await this.worker.on();

					await this.worker.addSSHKey(this.sshKeyPath);
				}

				const waitForSerialOutput = async(pattern, slice=0, retries=60, delay=1000) => this.utils.waitUntil(
					async () => this.worker.fetchSerial().then(
						serialLogs => serialLogs.split('\n')
																		.slice(slice)
																		.join('\n')
																		.match(pattern)
					), false, retries, delay
				);

				const testFullDiskEncryption = async () => Promise.all(
					[
						{ pattern: '/^\\/mnt\\/boot$/', name: 'Boot partition' },
						{ pattern: '/^\\/mnt\\/sysroot\\/active$/', name: 'Root partition' },
						{ pattern: '/^\\/mnt\\/state$/', name: 'State partition' },
						{ pattern: '/^\\/mnt\\/data$/', name: 'Data partition' },
					].map(args => test.resolveMatch(
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

				const testModuleVerification = async() => {
					await test.resolves(
						this.worker.executeCommandInHostOS('modprobe pcan_netdev', this.link),
						'Module with valid signature loads',
					);

					await this.worker.pushContainerToDUT(
						this.link,
						`${__dirname}/kernel-module-build`,
						'load',
					);

					return test.resolveMatch(
						this.worker.executeCommandInHostOS(
							'balena logs $(balena ps -aqf NAME=load)',
							this.link,
						),
						/Key was rejected by service/,
						'Unsigned module does not load',
					);
				}

				const testBootloaderIntegrity = async() => {
					return this.worker.executeCommandInHostOS(
						['balena', 'run', '--rm', '-v', '/mnt:/mnt', 'alpine', '/bin/sh', '-c',
							'"apk add --update --no-cache binutils && strip /mnt/boot/EFI/BOOT/bootx64.efi"'],
						this.link,
					).then(() => this.worker.executeCommandInHostOS('reboot', this.link)
					).then(() => test.resolves(
							waitForSerialOutput(/bootx64.efi: Access Denied/),
							'Firmware will not load bootloader that fails verification',
						)
					).then(resetWorker);
				};

				const testBootloaderConfigIntegrity = async () => {
					return this.worker.executeCommandInHostOS(
						['sed', '-i', 's/lockdown=integrity//', '/mnt/efi/EFI/BOOT/grub.cfg'],
						this.link
					).then(() => this.worker.executeCommandInHostOS('reboot', this.link)
					).then(() => test.resolves(
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

							waitForSerialOutput(/\x1B\[0m\x1B\[37m\x1B\[40m$/, 3), // eslint-disable-line no-control-regex
							'Bootloader will not load configuration that fails signature verification',
						)
					).then(resetWorker);
				};

				if (securebootSupported) {
					if (securebootEnabled) {
						await testFullDiskEncryption();
						await testModuleVerification();
						await testBootloaderIntegrity();
						await testBootloaderConfigIntegrity();
					} else {
						test.comment('Secure boot is not enabled');
					}
				} else {
					test.comment('Secure boot is not supported by firmware');
				}
			},
		},
	]
}
