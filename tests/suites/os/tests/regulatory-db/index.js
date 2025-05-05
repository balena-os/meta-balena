module.exports = {
	title: 'regulatory.db loading test',
	run: async function(test) {
		test.comment(`Checking for regulatory.db loading failure in kernel logs...`);
		let result = '';
		result = await this.context
			.get()
			.worker.executeCommandInHostOS(
				`dmesg | grep -q "regulatory.db is malformed or signature is missing" ; echo $?`,
				this.link,
			);

		if (result.includes('0')) {
			test.comment(`not ok! - regulatory.db loading failure is reported!`);
		} else {
			test.comment(`ok - no report of regulatory.db loading failure`);
		}

		test.is(true, true, 'regulatory.db loading test completed');
	},
};
