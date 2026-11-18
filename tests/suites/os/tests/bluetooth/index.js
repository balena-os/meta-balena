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
					let showOutput = await this.worker.executeCommandInWorker('bluetoothctl show');

					// Extract the MAC address using regex (matches "Controller XX:XX:XX:XX:XX:XX")
					let macMatch = showOutput.match(/Controller\s+([0-9A-Fa-f:]{17})/);

					if (!macMatch) {
						throw new Error('Failed to parse Bluetooth MAC address from "bluetoothctl show"');
					}

					let btMac = macMatch[1]; // Returns "2C:CF:67:0C:FD:81"
					test.comment(`Extracted DUT MAC Address: ${btMac}`);

					// leave the host discoverable for a longer period of time to prevent sporadic discover failures with Pi3
					await this.worker.executeCommandInWorker('bluetoothctl discoverable-timeout 1200');
					// make testbot bluetooth discoverable
					await this.worker.executeCommandInWorker('bluetoothctl discoverable on');
					await this.worker.executeCommandInWorker('bluetoothctl show');

					// scan for bluetooth devices on DUT, we retry a couple of times
					let scan = '';
					await this.utils.waitUntil(async () => {
						test.comment('Scanning for bluetooth devices...');
						// Use "name" to search for a specific MAC address - this is to avoid false negatives when there are too many 
						// devices returned by the scan
						scan = await this.context
							.get()
							.worker.executeCommandInHostOS(
								`hcitool name ${btMac}`,
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
		}],
	};
