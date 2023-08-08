module.exports = {
	title: 'Kernel and device-tree overlap test',
	run: async function(test) {
		test.comment(`Checking if the kernel or the device-tree have been overwritten`);
		let result = '';
		result = await this.context
			.get()
			.worker.executeCommandInHostOS(
				`if [ -e /mnt/boot/overlap_detected ]; then echo "Test failed"; else echo "OK"; fi;`,
				this.link,
			);

		if (!result.includes('OK')) {
			test.comment(`not ok! - kernel - dtb overlap detected`);
		} else {
			test.comment(`ok - no overlap detected`);
		}

		test.is(result.includes('OK'), true, 'Kernel - dtb overlap check completed');
	},
};
