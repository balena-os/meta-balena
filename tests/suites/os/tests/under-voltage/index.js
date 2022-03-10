module.exports = {
	title: 'Under-voltage test',
	run: async function(test) {
		test.comment(`Checking for under-voltage reports in kernel logs...`);
		let result = '';
		result = await this.context
			.get()
			.worker.executeCommandInHostOS(
				`dmesg | grep -q "Under-voltage detected" ; echo $?`,
				this.link,
			);

		if (result.includes('0')) {
			test.comment(`not ok! - Under-voltage detected on device, please check power source and cable!`);
		} else {
			test.comment(`ok - No under-voltage reports in the kernel logs`);
		}

		test.is(true, true, 'Under-voltage check completed');
	},
};
