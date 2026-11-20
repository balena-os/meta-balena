`use strict`;
const util = require('util');
const exec = util.promisify(require('child_process').exec);

// Make sure the device follows the latest release rather than being pinned
// (e.g. re-pinned to the preloaded release by a supervisor restart).
const ensureTrackingLatest = async (that, test) => {
  const device = that.cloud.balena.models.device;
  if (!(await device.isTrackingApplicationRelease(that.balena.uuid))) {
    test.comment(`Device is pinned to a release, unpinning so it follows the latest release`);
    await device.trackApplicationRelease(that.balena.uuid);
  }
}

// `recover` (optional) is called every 30 polls while the device isn't yet on the expected state,
// so the test can re-assert its intended target release if something else changed it.
const waitUntilServicesRunning = async(that, uuid, services, commit, test, recover) => {
  test.comment(`Waiting for device: ${uuid} to run services: ${services} at commit: ${commit}`);
  let lastObserved = 'no state observed';
  let polls = 0;
  try {
    await that.utils.waitUntil(async () => {
      polls++;
      const deviceServices = await that.cloud.balena.models.device.getWithServiceDetails(
        uuid
      );
      const current = deviceServices.current_services || {};
      lastObserved = JSON.stringify(services.map((service) => ({
        service,
        installs: (current[service] || []).map((s) => `${s.commit}:${s.status}`),
      })));
      // During a release swap the old and new container can both be listed, so check every entry
      const running = services.every((service) => {
        return (current[service] || []).some((s) => s.status === "Running" && s.commit === commit);
      });
      if (!running && recover && polls % 30 === 0) {
        await recover();
      }
      return running;
    }, false, 60 * 10, 1000);
  } catch (e) {
    throw new Error(`${e.message}. Last observed service state (commit:status): ${lastObserved}`);
  }
}

module.exports = {
  title: "Supervisor test suite",
  tests: [
    {
      title: "Provisioning without deltas",
      run: async function (test) {
        // Known starting state: supervisor settled (no pending restart / re-pin) and device following the latest release
        await this.waitForSupervisorStable(this.link);
        await ensureTrackingLatest(this, test);

        test.comment(`Disabling deltas`);
        await this.cloud.balena.models.device.configVar.set(
            this.balena.uuid,
            "BALENA_SUPERVISOR_DELTA",
            0
          );

        // add a comment to the end of the Dockerfile, to change the image when pushing.
        // The file has no trailing newline, so start with one or the comment lands on the CMD line.
        await exec(`printf '\\n#comment\\n' >> ${this.appPath}/containerA/Dockerfile.template`);
        test.comment(`Pushing release...`);

        let secondCommit = await this.cloud.pushReleaseToApp(
          this.balena.application, 
          `${this.appPath}`
        );

        await waitUntilServicesRunning(
          this,
          this.balena.uuid, 
          [this.appServiceName],
          secondCommit,
          test,
          // if the device got re-pinned to another release meanwhile, make it follow the latest again
          () => ensureTrackingLatest(this, test)
        )

        // device should have downloaded application without mentioning that deltas are being used
        let usedDeltas = await this.cloud.checkLogsContain(
          this.balena.uuid, 
          `Downloading delta for image`, 
          `Applied configuration change {"SUPERVISOR_DELTA":"0"}`
        );

        test.is(
          !usedDeltas,
          true,
          `Device shouldn't use deltas to download new release`
        );
        
        // re-enable deltas to save time later
        await this.cloud.balena.models.device.configVar.set(
          this.balena.uuid,
          "BALENA_SUPERVISOR_DELTA",
          1
        );
      },
    },
    {
      title: "Override lock test",
      run: async function (test) {
        let firstCommit = await this.cloud.balena.models.application.getTargetReleaseHash(
          this.balena.application
        )

        // The app must be running on the expected release before we lock it, otherwise
        // there is no container to exec into (and nothing for the lock to protect)
        await this.waitForSupervisorStable(this.link);
        await waitUntilServicesRunning(
          this,
          this.balena.uuid,
          [this.appServiceName],
          firstCommit,
          test,
          () => ensureTrackingLatest(this, test)
        )

        // create a lockfile
        let createLockfile = await this.cloud.executeCommandInContainer(
          `bash -c '(flock -x -n 200)200>/tmp/balena/updates.lock'`,
          this.appServiceName,
          this.balena.uuid)

        // fail here, with a clear reason, if the lockfile does not exist
        let lockfileCheck = await this.cloud.executeCommandInContainer(
          `ls /tmp/balena/updates.lock`,
          this.appServiceName,
          this.balena.uuid)
        test.ok(
          lockfileCheck.includes('updates.lock'),
          `Lockfile should exist in the ${this.appServiceName} container`
        )

        console.log('Lockfile has been created...')
        //pin to a previous, different commit
        await this.cloud.balena.models.device.pinToRelease(
          this.balena.uuid, 
          this.balena.initialCommit
        );

        let updatesLocked = false;
        await this.utils.waitUntil(async () => {
          updatesLocked = await this.cloud.checkLogsContain(
            this.balena.uuid, 
            `Updates are locked`
          );

          return updatesLocked === true
        }, false, 100, 5 * 1000);

        test.ok(updatesLocked, `Update lock message should appear in logs`)

        // check original application is downloaded - shouldn't be installed
        await this.utils.waitUntil(async () => {
          test.comment(
            "Checking if old release is still running..."
          );
          let services = await this.cloud.balena.models.device.getWithServiceDetails(
              this.balena.uuid
            );
          let originalRunning = false;
          services.current_services[this.appServiceName].forEach((service) => {
            if (
              service.commit === firstCommit &&
              service.status === "Running"
            ) {
              originalRunning = true;
            }
          });
          return originalRunning;
        }, false, 60, 5 * 1000);

        test.ok(
          true,
          `Original release should still be running due to lockfile`
        );

        // enable lock override
        await this.cloud.balena.models.device.configVar.set(
            this.balena.uuid,
            "BALENA_SUPERVISOR_OVERRIDE_LOCK",
            1
          );

        await waitUntilServicesRunning(
          this,
          this.balena.uuid, 
          [this.appServiceName], 
          this.balena.initialCommit,
          test
        )

        test.ok(
          true,
          `Second release should now be running, as override lock was enabled`
        );

        // remove lockfile
        await this.cloud.executeCommandInContainer(
          `rm /tmp/balena/updates.lock`, 
          this.appServiceName,
          this.balena.uuid)
      },
    },
    {
      title: 'Update supervisor randomized timer',
      run: async function(test) {
        const nextTriggers = []
        return this.waitForServiceState(
          'update-balena-supervisor.service',
          'inactive',
          this.link
        ).then(async () => {
          let samples = 0
          do {
              nextTriggers.push( await this.worker.executeCommandInHostOS(
                  `date -s "+2 hours" > /dev/null`,
                  this.link
                ).then(async () => {
                  let trigger;
                  await this.utils.waitUntil(async () => {
                    // on slower hardware this command can return an empty string so don't proceed
                    // until we have a value for trigger
                    trigger = await this.worker.executeCommandInHostOS(
                      `systemctl status update-balena-supervisor.timer | grep "Trigger:" | awk '{print $4}'`,
                      this.link
                    );
                    return trigger !== "";
                  }, false, 20, 500)
                  return trigger;
                })
              );
              samples = samples + 1;
          } while (samples < 3);
          console.log(nextTriggers)
          test.ok (
            // check that all results are unique
            (new Set(nextTriggers)).size === nextTriggers.length,
            'Balena supervisor updater will run on a randomized timer'
          )
        }).then(async () => {
          /* Restore current time */
          await this.worker.executeCommandInHostOS(
            `chronyc -a 'burst 4/4'`,
            this.link)
        })
      },
    },
  ],
};
