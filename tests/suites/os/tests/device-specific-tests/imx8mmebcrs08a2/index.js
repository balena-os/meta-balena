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


module.exports = {
	deviceType: {
		type: 'object',
		required: ['slug'],
		properties: {
			slug: {
				type: 'string',
				const: 'imx8mmebcrs08a2',
			},
		},
	},
	title: 'imx8mmebcrs08a2 dtb overlap test',
	run: async function(test) {
        const REBOOTS = 5

        const serial = await this.worker.executeCommandInHostOS(
                `cat /proc/device-tree/serial-number`,
                this.link,
        );

        test.comment(`Serial is: ${serial}`)

        let serialCheck = true;
        for(let i=0; i<REBOOTS; i++){
            test.comment(`Rebooting DUT for ${i+1}/${REBOOTS}`);
		    await this.worker.rebootDut(this.link);
            let check = await this.worker.executeCommandInHostOS(
                `cat /proc/device-tree/serial-number`,
                this.link,
            )
            serialCheck = (check === serial);
        }
        test.ok(serialCheck, `Serial number should not change after ${REBOOTS} reboots`)
    }
}
