module.exports = {
	deviceType: {
		type: 'object',
		required: ['slug'],
		properties: {
			slug: {
				type: 'string',
				const: 'beaglebone-black',
			},
		},
	},
	title: 'BeagleBone Black u-boot overlay test: deactivate HDMI',
	run: async function(test) {
		test.comment('Checking that overlays are not enabled ...');
		const resp_init = await this.context
			.get()
			.worker.executeCommandInHostOS(
				'ls -al /proc/device-tree/chosen/',
				this.context.get().link,
			);

		test.is(
			resp_init.includes('overlays'),
			false,
			'u-boot overlays are disabled (overlay directory is not present in /proc/device-tree/chosen/)',
		);

		test.comment('Enabling u-boot overlays ...');
		await this.worker.executeCommandInHostOS(
				`echo "enable_uboot_overlays=1" >> /mnt/boot/uEnv.txt`,
				this.link,
			);

		// Reboot the DUT to pick up the changes
		await this.worker.rebootDut(this.link);

		const resp_before = await this.context
			.get()
			.worker.executeCommandInHostOS(
				'ls -al /proc/device-tree/chosen/overlays/',
				this.link,
			);

		test.is(
			resp_before.includes('BB-HDMI-TDA998x-00A0'),
			true,
			'HDMI enabled (overlay present in /proc/device-tree/chosen/overlays/)',
		);

		test.comment('Disabling HDMI ...');
		await this.context
			.get()
			.worker.executeCommandInHostOS(
				`echo "disable_uboot_overlay_video=1" >> /mnt/boot/uEnv.txt`,
				this.link,
			);

		// Reboot the DUT to pick up the changes
		await this.worker.rebootDut(this.link);

		const resp_after = await this.context
			.get()
			.worker.executeCommandInHostOS(
				'ls -al /proc/device-tree/chosen/overlays/',
				this.link,
			);

		test.is(
			resp_after.includes('BB-HDMI-TDA998x-00A0'),
			false,
			'HDMI is now disabled (overlay not present in /proc/device-tree/chosen/overlays/)',
		);

		// Revert the uEnv.txt changes and reboot the DUT so when we finish the test we have the initial setup
		test.comment('Revert changes to uEnv.txt and reboot ...');
		await this.context
			.get()
			.worker.executeCommandInHostOS(
				`head -n -2 /mnt/boot/uEnv.txt > /mnt/boot/temp_uEnv.txt && mv /mnt/boot/temp_uEnv.txt /mnt/boot/uEnv.txt`,
				this.context.get().link,
			);
		await this.context.get().worker.rebootDut(this.context.get().link);

		const resp_final = await this.context
			.get()
			.worker.executeCommandInHostOS(
				'ls -al /proc/device-tree/chosen/',
				this.context.get().link,
			);

		test.is(
			resp_final.includes('overlays'),
			false,
			'u-boot overlays have been disabled (overlay directory is not present in /proc/device-tree/chosen/)',
		);
	},
};
