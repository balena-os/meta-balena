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

'use strict';

module.exports = {
	title: 'zram is enabled and configured as swap',
	run: async function(test) {
		const swaps = await this.worker.executeCommandInHostOS(
			'cat /proc/swaps',
			this.link,
		).then((output) => {
			// Convert the output of /proc/swaps into a list of objects
			return output
				.trim().split('\n').slice(1).map((entry) => {
				const swapKeys = ['filename', 'type', 'size', 'used', 'priority'];
				const swapValues = entry.split(/(\s+)/).filter(e => e.trim().length > 0);
				return Object.assign(
					...swapKeys.map((k, i) => ({[k]: swapValues[i]}))
				);
			});
		});

		const totalMem = await this.worker.executeCommandInHostOS(
			`cat /proc/meminfo | head -1 | awk '{print $2}'`,
			this.link,
		);

		test.equal(swaps.length, 1, 'There should be one swap');

		const swap = swaps[0];
		test.match(swap.filename, /\/dev\/zram?/, 'Swap should be a zram device');

		const maxSwap = 4096000;
		const expectedSwap = Math.min(totalMem / 2, maxSwap);
		// Swap size is calculated as a percentage, so allow a little wiggle room to account for HW differences. 
		// This value is derived from the current worst case we have seen
		const delta = Math.abs(expectedSwap - swap.size);
		test.ok(
			delta < 50,
			'Swap should be the lesser of either half the total memory, or 4 GB'
		);
	},
}
