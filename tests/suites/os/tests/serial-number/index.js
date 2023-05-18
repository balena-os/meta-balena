'use strict';
const Bluebird = require('bluebird');

module.exports = {
	title: 'serial number test',
    // Only perform this test on physcial DUTs, not QEMU
    workerContract: {
        type: 'object',
        required: ['workerType'],
        properties: {
            workerType: {
                anyOf:[
                    {
                        type: 'string',
                        const: 'testbot_hat'
                    },
                    {
                        type: 'string',
                        const: 'autokit'
                    },
                ]
            },
        },
    },
    run: async function(test) {
        // prevent masses of retries in the case of the file not existing
        const retryArgs = {
            max_tries: 1,
            interval: 1000,
            throw_original: true,
        }
        // This will work on arm devices
        let serial = await Bluebird.any([
            this.worker.executeCommandInHostOS('cat /proc/device-tree/serial-number', this.link, retryArgs),
            this.worker.executeCommandInHostOS('cat /proc/device-tree/product-sn', this.link, retryArgs),
            this.worker.executeCommandInHostOS('cat /sys/devices/soc0/serial_number', this.link, retryArgs),
        ]);
        
        test.comment(`Serial number is: ${serial}`);

        const pattern = /^[\dA-Za-z]{4,}/;
        const serialCheck = pattern.test(serial.trim());
        test.ok(serialCheck, 'Serial number should be found on device and should look valid');
    }
};
