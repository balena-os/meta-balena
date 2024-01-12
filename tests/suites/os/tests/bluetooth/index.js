const Bluebird = require('bluebird');
const exec = Bluebird.promisify(require('child_process').exec);

module.exports = {
	title: 'Bluetooth tests',
	deviceType: {
		type: 'object',
		required: ['data'],
		properties: {
			data: {
				type: 'object',
				required: ['connectivity'],
				properties: {
					connectivity: {
						type: 'object',
						required: ['bluetooth'],
						properties: {
							bluetooth: {
								type: 'boolean',
								const: true,
							},
						},
					},
				},
			},
		},
	},
	tests: [
		{
			title: 'Bluetooth scanning test',
			run: async function(test) {
				if(this.workerContract.workerType === `qemu`){
					test.pass(
						'Qemu worker used - skipping bluetooth test',
					);
				} else {
					// get the testbot bluetooth name
					let btName = await this.worker.executeCommandInWorker('bluetoothctl show | grep Name');
					let btNameParsed = /(.*): (.*)/.exec(btName); // the bluetoothctl command returns "Name: <btname>", so extract the <btname here>

          // leave the host discoverable for a longer period of time to prevent sporadic discover failures with Pi3
          await this.worker.executeCommandInWorker('bluetoothctl discoverable-timeout 1200');
          // make testbot bluetooth discoverable
					await this.worker.executeCommandInWorker('bluetoothctl discoverable on');

					// scan for bluetooth devices on DUT, we retry a couple of times
					let scan = '';
					await this.utils.waitUntil(async () => {
						test.comment('Scanning for bluetooth devices...');
						scan = await this.context
							.get()
							.worker.executeCommandInHostOS(
								'hcitool scan',
								this.link,
							);
						return scan.includes(btNameParsed[2]);
					});

					test.is(
						scan.includes(btNameParsed[2]),
						true,
						'DUT should be able to see testbot when scanning for bluetooth devices',
					);

					test.comment('Checking if BD Address is initialized');
					const devMac = await this.context
							.get()
							.worker.executeCommandInHostOS(
								'hcitool dev',
								this.link,
							);

					test.is(
						devMac.includes('AA:AA:AA:AA:AA:AA'),
						false,
						'BD Address should not be AA:AA:AA:AA:AA:AA',
					);
				}
			},
		},
	],
};
