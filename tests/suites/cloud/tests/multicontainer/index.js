/* Copyright 2019 balena
 *
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
const util = require('util');
const exec = util.promisify(require('child_process').exec);

const waitUntilServicesRunning = async(that, uuid, services, commit, test) => {
  await that.utils.waitUntil(async () => {
    test.comment(`Waiting for device: ${uuid} to run services: ${services} at commit: ${commit}`);
    let deviceServices = await that.cloud.balena.models.device.getWithServiceDetails(
      uuid
      );
    let running = false
    running = services.every((service) => {
      return (deviceServices.current_services[service][0].status === "Running") && (deviceServices.current_services[service][0].commit === commit)
    })
    return running;
  }, false, 60, 5 * 1000)
}

module.exports = {
  title: "Multicontainer app tests",
  run: async function (test) {
    const moveApplicationName = `${
      this.balena.application
    }_MoveDevice`;

    // create new application
    await this.cloud.balena.models.application.create({
      name: `${this.balena.name}_MoveDevice`,
      deviceType: this.os.deviceType,
      organization: this.balena.organization,
    });

    this.context.set({
      moveApp: moveApplicationName,
    });

    this.suite.context.set({
      moveApp: moveApplicationName,
    });

    // Remove this app at the end of the test suite
    this.suite.teardown.register(() => {
      this.log(`Removing application ${moveApplicationName}`);
      try{
        return this.cloud.balena.models.application.remove(moveApplicationName);
      }catch(e){
        this.log(`Error while removing application...`)
      }
    });

    // push multicontainer app release to new app
    test.comment(`Cloning repo...`);
    await exec(
      `git clone https://github.com/balena-io-examples/multicontainer-getting-started.git ${__dirname}/app`
    );

    test.comment(`Pushing release...`);
    const initialCommit = await this.cloud.pushReleaseToApp(moveApplicationName, `${__dirname}/app`)
    this.suite.context.set({
      multicontainer: {
        initialCommit: initialCommit
      }
    })
  },
  tests: [
    {
      title: "Move device to multicontainer App",
      run: async function (test) {
        // move device to new app
        await this.cloud.balena.models.device.move(
            this.balena.uuid,
            this.moveApp
          );

        await waitUntilServicesRunning(
          this,
          this.balena.uuid, 
          [`frontend`, `proxy`, `data`], 
          this.multicontainer.initialCommit,
          test
        )

        test.ok(true, "All services running");
      },
    },
    {
      title: "Set device environment variables",
      run: async function (test) {
        let key = "deviceVar";
        let value = "value";

        // set device variable
        await this.cloud.balena.models.device.envVar.set(
            this.balena.uuid,
            key,
            value
          );

        // Check that device env variable is present in each service
        let services  = [`frontend`, `proxy`, `data`]
        await this.utils.waitUntil(async () => {
          let results = {}
          for (let service of services){
            let env = await this.cloud.executeCommandInContainer(`env`, service, this.balena.uuid)
            if (env.includes(`${key}=${value}\n`)){
              results[service] = true
            } else {
              results[service] = false
            }
          }
          return services.every((service) => {
            return results[service] === true
          })
        }, false, 60, 5 * 1000);

        test.ok(true, `Should see device env variable`);
      },
    },
    {
      title: "Set service environment variables",
      run: async function (test) {
        let key = "serviceVar";
        let value = "value";

        let services = await this.cloud.balena.models.device.getWithServiceDetails(
            this.balena.uuid
          );

        // set device service variable for frontend service
        await this.cloud.balena.models.device.serviceVar.set(
            this.balena.uuid,
            services.current_services.frontend[0].service_id,
            key,
            value
          );

        // Check to see if variable is present in front end service
        await this.utils.waitUntil(async () => {
          test.comment("Checking to see if variables are visible...");
          let env = await this.cloud.executeCommandInContainer(`env`, `frontend`, this.balena.uuid)

          return env.includes(`${key}=${value}\n`);
        }, false, 60, 5 * 1000);
        test.ok(true, `Should service env var in service it was set for`);
      },
    },
    {
      title: "Move device back to original app",
      run: async function (test) {
        // move device to new app
        await this.cloud.balena.models.device.move(
            this.balena.uuid,
            this.balena.application
          );

        // get latest commit
        let commit = await this.cloud.balena.models.application.getTargetReleaseHash(
          this.balena.application
        )

        await waitUntilServicesRunning(
          this,
          this.balena.uuid, 
          [this.appServiceName], 
          commit,
          test
        )

        test.ok(
          true,
          `Device should have been moved back to original app, and be running its service`
        );

        // wait until cloud sees device as running original service release - this will allow us to delete the application after
        await this.utils.waitUntil(async() => {
          let deviceHash = await this.cloud.balena.models.device.getTargetReleaseHash(
            this.balena.uuid
          )
          return deviceHash === commit
        })

        test.ok(
          true,
          `Device has original app release hash`
        )
      },
    },
  ],
};
