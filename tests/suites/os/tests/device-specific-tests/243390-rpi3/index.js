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
				const: '243390-rpi3',
			},
		},
	},
	title: '243390-rpi3 - CUS/EUS chipsets test',
	run: async function(test) {
		const testHelpers = fs
			.readFileSync(`${__dirname}/assets/helpers.sh`)
			.toString();

		/* TC55, TC56 */
		let output = await this.context
			.get()
			.worker.executeCommandInHostOS(
				`${testHelpers} test_interface_naming`,
				this.link,
			);

		test.is(
			output.includes('passed'),
			true,
			'Wireless interfaces are named correctly',
		);

		/* TC50, TC51, TC52, TC53 */
		output = await this.context
			.get()
			.worker.executeCommandInHostOS(
				`${testHelpers} add_hotspot_connection`,
				this.link,
			);

		test.is(
			output.includes('added'),
			true,
			'NetworkManager hotspot connection added',
		);

		await this.worker.rebootDut(this.link);

		await this.utils.waitUntil(
			async () => {
				output = await this.context.get().worker.executeCommandInHostOS(`${testHelpers} test_hotspot`, this.link);
				return output.includes('passed');
			},
			true,
			10,
			5 * 1000
		);

		test.is(output.includes('passed'), true, 'Wifi hotspot is active');

		await this.context.get().worker.executeCommandInHostOS(`${testHelpers} cleanup_hotspot_connections`, this.link);
		await this.worker.rebootDut(this.link);
	},
};
