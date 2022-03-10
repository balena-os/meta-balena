/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* NOTE: Ensure DIO module ports O1 and I1 are connected together with a jumper wire */

test_repository = 'https://raw.githubusercontent.com/balena-io-playground/revpi-core3-test/master/'
config_file = 'config.rsc'
dio_binary = 'piTest'

module.exports = {
	deviceType: {
		type: 'object',
		required: ['slug'],
		properties: {
			slug: {
				type: 'string',
				const: 'revpi-core-3',
			},
		},
	},
	title: 'RevPi Core 3 DIO module test',
	run: async function(test) {
					await this.context
						.get()
						.worker.executeCommandInHostOS(
								`cd /mnt/boot/ && wget ${test_repository}${config_file} -O ${config_file}`,
								this.link,
						);

		await this.worker.rebootDut(this.link);

		await this.context
				.get()
				.worker.executeCommandInHostOS(
						`cd /tmp/ && wget ${test_repository}bin/${dio_binary} -O ${dio_binary} && chmod +x ./${dio_binary}`,
						this.link,
				);

		// Set output O1 to 1 and ensure input I1 reads the value 1
		await this.context
				.get()
				.worker.executeCommandInHostOS(
						`/tmp/${dio_binary} -w O_1,1`,
						this.link,
				);

		output = await this.context
				.get()
				.worker.executeCommandInHostOS(
						`sleep 1 && /tmp/${dio_binary} -1r I_1`,
						this.link,
				);

		test.is(
				output.includes('Bit value: 1'),
				true,
				'Test binary should return: Bit value: 1',
		);

		// Set output O1 to 0 and ensure input I1 reads this value
		await this.context
				.get()
				.worker.executeCommandInHostOS(
						`/tmp/${dio_binary} -w O_1,0`,
						this.link,
				);

		output = await this.context
				.get()
				.worker.executeCommandInHostOS(
						`sleep 1 && /tmp/${dio_binary} -1r I_1`,
						this.link,
				);

		test.is(
				output.includes('Bit value: 0'),
				true,
				'Test binary should return: Bit value: 0',
		);
	},
};
