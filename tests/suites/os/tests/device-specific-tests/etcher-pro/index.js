const { delay } = require('bluebird');

module.exports = {
	deviceType: {
		type: 'object',
		required: ['slug'],
		properties: {
			slug: {
				type: 'string',
				const: 'etcher-pro',
			},
		},
	},
	title: 'Etcher pro fan block test',
	run: async function(test) {
        // push fan control block to DUT
        const ip = await this.worker.ip(this.link);

		await this.context
			.get()
			.worker.pushContainerToDUT(ip, __dirname, 'fan-control');

        // wait for 5 seconds to ensure no crashlooping
        await delay(5000);
    
        // execute command a container
        const res = await this.context
			.get()
			.worker.executeCommandInContainer('echo Hello', 'fan-control', this.link);

        test.ok(res, 'Hello', 'Should be able to run command inside fan-block');
    }
};
