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

"use strict";

const request = require("request-promise");
const SUPERVISOR_PORT = 48484;

module.exports = {
  title: "Device Tree tests",
  tests: [
    {
      title: "DToverlay & DTparam tests",
      run: async function (test) {
        const ip = await this.context.get().worker.ip(this.context.get().link);

        // Wait for supervisor API to start
        await this.context.get().utils.waitUntil(async () => {
          return (
            (await request({
              method: "GET",
              uri: `http://${ip}:${SUPERVISOR_PORT}/ping`,
            })) === "OK"
          );
        }, false);

        const targetState = {
          // Whichever target state becomes successful. Add it here. 
        }

        // FETCH SUPERVISOR KEY from DB
        // you can get it from the db with the following command sequence in a host terminal:
        // balena exec - ti resin_supervisor node
        // sqlite3 = require('sqlite3')
        // db = new sqlite3.Database('/data/database.sqlite')
        // db.all('select * from apiSecret', console.log)
        // Select the key with the global label

        // Setting the DToverlay variables
        // Understand why this doesn't need credentials or SUPERVISOR_API_KEY
        const setTargetState = await request({
          method: "POST",
          headers: {
            'Content-Type': 'application/json',
          },
          json: true,
          body: targetState,
          uri: `http://${ip}:${SUPERVISOR_PORT}/v2/local/target-state`,
        });

        test.equal(setTargetState, { "status": "success", "message": "OK" }, "DToverlay & DTparam configured successfully");

        await this.context.get().utils.waitUntil(async () => {
          test.comment("Waiting for DUT to come back online...");
          return (
            (await this.context
              .get()
              .worker.executeCommandInHostOS(
                '[[ ! -f /tmp/reboot-check ]] && echo "pass"',
                this.context.get().link
              )) === "pass"
          );
        }, false);

        // Get the current target state of device
        const currentState = await request({
          method: "GET",
          uri: `http://${ip}:${SUPERVISOR_PORT}/v2/local/target-state`,
        });

        test.equal(currentState.state.local.config["HOST_CONFIG_dtoverlay"], targetState.local.config["HOST_CONFIG_dtoverlay"], "DToverlay successfully set by Supervisor")
        test.equal(currentState.state.local.config["HOST_CONFIG_dtparam"], targetState.local.config["HOST_CONFIG_dtparam"], "DTparam successfully set by Supervisor")

        const overlayConfigTxt = this.context
          .get()
          .worker.executeCommandInHostOS(
            `cat /mnt/boot/config.txt | grep SOMETHING_DTOVERLAY`,
            this.context.get().link
          );

        test.equal(overlayConfigTxt, targetState.local.config["HOST_CONFIG_dtoverlay"], "DToverlay successfully set in config.txt")

        const paramConfigTxt = this.context
          .get()
          .worker.executeCommandInHostOS(
            `cat /mnt/boot/config.txt | grep SOMETHING_DTPARAM`,
            this.context.get().link
          );

        test.equal(paramConfigTxt, targetState.local.config["HOST_CONFIG_dtparam"], "DTparam successfully set in config.txt")

      },
    },
  ],
};
