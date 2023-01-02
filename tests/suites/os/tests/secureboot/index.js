'use strict';

module.exports = {
	title: 'secure boot tests',
	tests: [
		{
			title: 'check secure boot',
			run: async function(test) {
				const securebootSupported = await this.worker.executeCommandInHostOS(
					['ls', '/sys/firmware/efi/efivars/SecureBoot-*', '&>/dev/null',
						'&&', 'echo', 'true',
						'||', 'echo', 'false'
					],
					this.link,
				).then(output => { return output === 'true'});

				if (securebootSupported) {
					return test.resolves(
						Promise.all(
							[
								test.resolveMatch(
									this.worker.executeCommandInHostOS(
										[
											'dmesg', '|', 'grep', '-q', '"Secure boot enabled"',
											'&&', 'echo', 'true', '||', 'true'
										],
										this.link,
									),
									/true/,
									'Secure boot is enabled',
								),
							] + [
								{ pattern: '/^\\/mnt\\/boot$/', name: 'Boot partition' },
								{ pattern: '/^\\/mnt\\/sysroot\\/active$/', name: 'Root partition' },
								{ pattern: '/^\\/mnt\\/state$/', name: 'State partition' },
								{ pattern: '/^\\/mnt\\/data$/', name: 'Data partition' },
							].map(args => {
								return test.resolveMatch(
									this.worker.executeCommandInHostOS(
										[
											'lsblk', '-nlo', 'MOUNTPOINT,TYPE',
											'|', 'awk', `'$1 ~ ${args.pattern} { print $2 }'`
										],
										this.link,
									),
									/crypt/,
									`${args.name} is encrypted`,
								);
							}),
						),
						'Secure boot is correctly configured'
					);
				} else {
					test.comment('Secure boot is not supported by firmware');
				}
			},
		},
	]
}
