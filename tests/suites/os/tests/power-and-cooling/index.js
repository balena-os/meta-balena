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

const fs = require('fs');

module.exports = {
	deviceType: {
		type: 'object',
		required: ['slug'],
		properties: {
			slug: {
				type: 'string',
				enum: [
					'jetson-agx-orin-devkit-64gb',
					'jetson-agx-orin-devkit',
					'jetson-orin-nano-devkit-nvme',
					'jetson-orin-nano-seeed-j3010',
					'jetson-orin-nx-seeed-j4012',
					'jetson-orin-nx-xavier-nx-devkit'
					],
			},
		},
	},
	title: 'Jetson Orin power mode and fan profile tests',
	run: async function(test) {
		const testHelpers = fs
			.readFileSync(`${__dirname}/assets/helpers.sh`)
			.toString();

		let output = await this.context
			.get()
			.worker.executeCommandInHostOS(
				`${testHelpers} test_fan_profile`,
				this.link,
			);

		test.is(
			output.includes('passed'),
			true,
			'Fan profile test passed',
		);

		output = await this.context
			.get()
			.worker.executeCommandInHostOS(
				`${testHelpers} set_power_mode`,
				this.link,
			);

		test.is(
			output.includes('set'),
			true,
			'Power mode was set',
		);

		await this.worker.rebootDut(this.link);

		await this.utils.waitUntil(
			async () => {
				output = await this.context.get().worker.executeCommandInHostOS(`${testHelpers} test_power_mode`, this.link);
				return output.includes('passed');
			},
			true,
			10,
			5 * 1000
		);

		test.is(output.includes('passed'), true, 'Power mode test passed');
	},
};
