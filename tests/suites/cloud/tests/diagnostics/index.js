`use strict`;
const request = require('request-promise');
const ACTIONS_URL = `https://actions.balena-devices.com/v1`;

module.exports = {
  title: "Device Diagnostics suite",
  tests: [
    {
      title: "Device Health Checks",
      run: async function (test) {
        // wait until we receive a response from the device saying checks are in progress
        await this.context.get().utils.waitUntil(async() => {
            test.comment(`Triggering device healthcheck via proxy...`);
            let triggerHealthCheck = await request({
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${this.context.get().balena.apiKey}`
                },
                json: true,
                uri: `${ACTIONS_URL}/${this.context.get().balena.uuid}/checks`,
            });

            return (triggerHealthCheck.status === 'in_progress') && (triggerHealthCheck.action === 'checks');
        }, false);

        // once triggered, keep checking until the healthcheck is complete
        let resultsHealthCheck = {};
        await this.context.get().utils.waitUntil(async() => {
            test.comment(`Waiting for healthcheck result...`);
            resultsHealthCheck = await request({
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${this.context.get().balena.apiKey}`
                },
                json: true,
                uri: `${ACTIONS_URL}/${this.context.get().balena.uuid}/checks`,
            });

            return (resultsHealthCheck.status === 'done');
        }, false);

        // Once results are retreived, check them for any errors
        test.true(true, `Checks done, version: ${resultsHealthCheck.stdout.diagnose_version}`);
        for(check of resultsHealthCheck.stdout.checks){
            // device will always fail the balenaOS check - as we won't have published that release yet
            if(check.name === 'check_balenaOS'){
                test.comment(`Check: ${check.name}, Status: ${check.status}`)
            } else {
                test.is(check.success, true, `Check: ${check.name}, Status: ${check.status}`)
            }
        }
      }
    },
  ],
};
