"use strict";
module.exports = {
  title: "Image preload test",
  run: async function (test) {
    // make sure DUT is online
    await this.utils.waitUntil(() => {
      return this.cloud.balena.models.device.isOnline(this.balena.uuid);
    }, false, 60, 5 * 1000);

    // wait until the service is running
    await this.cloud.waitUntilServicesRunning(
      this.balena.uuid, 
      [`main`], 
      this.balena.initialCommit
    )

    test.ok(true, `Preload commit hash should be ${this.balena.initialCommit}`);

    // give it some time to be sure no release is downloaded
    await new Promise(resolve => setTimeout(resolve, 1000*60));

    let downloadedLog = await this.cloud.checkLogsContain(
      this.balena.uuid, 
      `Downloading`, 
      `Supervisor starting`
    );

    test.ok(!downloadedLog, `Device should run application without downloading`);
  },
};
