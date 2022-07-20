"use strict";

const request = require('request-promise');

module.exports = {
  title: "Image preload test",
  run: async function (test) {

    // if test is being done on physical DUT via the testbot, check that the preloaded application is working
    if(this.workerContract.workerType !== `qemu`){
      // we should be able to see the app starting.
      const ip = await this.worker.ip(this.link);
      
      // create tunnel to DUT port 80
      console.log(`Creating tunnel to DUT port 80...`)
      await this.worker.createTunneltoDUT(this.link, 80, 8899);
      await this.utils.waitUntil(async () => {
        console.log(`Checking preloaded app is running... `)
        let page = await request({
          method: 'GET',
          uri: `http://${ip}:80`,
        })
        return page.includes("Welcome to balena!"); 
      }, false);

      test.ok(true, `Web page should be exposed on port 80 of DUT`)
      // When we confirm the app has started, then re-enable internet access to DUT
      await this.worker.executeCommandInWorker('sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"');
    }

    // make sure DUT is online
    console.log(`Waiting for DUT to be online in dashboard`)
    await this.utils.waitUntil(() => {
      return this.cloud.balena.models.device.isOnline(this.balena.uuid);
    }, false, 60, 5 * 1000);

    // wait until the service is running
    await this.cloud.waitUntilServicesRunning(
      this.balena.uuid, 
      [this.appServiceName], 
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

    this.log("Unpinning device from release");
    await this.cloud.balena.models.device.trackApplicationRelease(
      this.balena.uuid
    );

    await this.utils.waitUntil(async () => {
      console.log('Waiting for device to be running latest release...');
      return await this.cloud.balena.models.device.isTrackingApplicationRelease(
        this.balena.uuid
      );
    }, false, 180, 5 * 1000);
  },
};
