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
		test.comment('Enabling u-boot overlays ...');
		await this.context
			.get()
			.worker.executeCommandInHostOS(
				`echo "enable_uboot_overlays=1" > /mnt/boot/uEnv.txt`,
				this.context.get().link,
			);

		// Reboot the DUT to pick up the changes
		await this.context.get().worker.rebootDut(this.context.get().link);

		const resp_before = await this.context
			.get()
			.worker.executeCommandInHostOS(
				'ls -al /proc/device-tree/chosen/overlays/',
				this.context.get().link,
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
				this.context.get().link,
			);

		// Reboot the DUT to pick up the changes
		await this.context.get().worker.rebootDut(this.context.get().link);

		const resp_after = await this.context
			.get()
			.worker.executeCommandInHostOS(
				'ls -al /proc/device-tree/chosen/overlays/',
				this.context.get().link,
			);

		test.is(
			resp_after.includes('BB-HDMI-TDA998x-00A0'),
			false,
			'HDMI is now disabled (overlay not present in /proc/device-tree/chosen/overlays/)',
		);
	},
};
