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

'use strict';

const VOLUME_NAME = 'test_extra_firmware';
const SYSFS_PATH = '/sys/module/firmware_class/parameters/path';
const CONFIG_PATH = '/mnt/boot/config.json';
const CONFIG_BACKUP_PATH = '/mnt/state/config.json.extra-firmware-test-backup';

const backupConfig = async (context, link, test) => {
    test.comment('Backing up config.json...');
    await context
        .get()
        .worker.executeCommandInHostOS(
            `cp ${CONFIG_PATH} ${CONFIG_BACKUP_PATH}`,
            link,
        );
    test.comment(`config.json backed up to ${CONFIG_BACKUP_PATH}`);
};

const restoreConfig = async (context, link, test) => {
    test.comment('Restoring config.json...');
    await context
        .get()
        .worker.executeCommandInHostOS(
            `mv ${CONFIG_BACKUP_PATH} ${CONFIG_PATH}`,
            link,
        );
    test.comment('config.json restored');
};

const createTestVolume = async (context, link, test) => {
    test.comment('Creating test docker volume...');

    // Create volume
    await context
        .get()
        .worker.executeCommandInHostOS(
            `balena volume create ${VOLUME_NAME} || true`,
            link,
        );

    // Verify volume exists
    const volumeExists = await context
        .get()
        .worker.executeCommandInHostOS(
            `balena volume inspect ${VOLUME_NAME} >/dev/null 2>&1 && echo exists || echo missing`,
            link,
        );
    test.is(volumeExists.trim(), 'exists', `Docker volume ${VOLUME_NAME} should exist`);

    test.comment(`Volume ${VOLUME_NAME} created`);
};

const configureExtraFirmwareAndVerifyServiceTriggered = async (context, link, test) => {
    test.comment('Configuring os.kernel.extraFirmwareVol in config.json...');

    // Get the current monotonic time (in microseconds) before making the config change
    const monotonicTimeBefore = await context
        .get()
        .worker.executeCommandInHostOS(
            `cat /proc/uptime | awk '{printf "%.0f", $1 * 1000000}'`,
            link,
        );
    test.comment(`Monotonic time before config change: ${monotonicTimeBefore.trim()}`);

    // Update config.json with the extra firmware volume
    await context
        .get()
        .worker.executeCommandInHostOS(
            `jq '.os.kernel.extraFirmwareVol = "${VOLUME_NAME}"' ${CONFIG_PATH} > /tmp/config.json && cp /tmp/config.json ${CONFIG_PATH}`,
            link,
        );

    // Verify the config was set
    const configValue = await context
        .get()
        .worker.executeCommandInHostOS(
            `jq -r '.os.kernel.extraFirmwareVol // empty' ${CONFIG_PATH}`,
            link,
        );
    test.is(configValue.trim(), VOLUME_NAME, 'config.json should have extraFirmwareVol set');

    test.comment('config.json updated, waiting for service to be triggered automatically...');

    // Poll for service execution (max 5 attempts, 1 second apart)
    // Check if ExecMainExitTimestampMonotonic is greater than our recorded time
    const maxAttempts = 5;
    let serviceTriggered = false;
    const timeBeforeMicros = parseInt(monotonicTimeBefore.trim(), 10);

    for (let i = 1; i <= maxAttempts; i++) {
        await new Promise(r => setTimeout(r, 1000));

        const exitTimestamp = await context
            .get()
            .worker.executeCommandInHostOS(
                `systemctl show os-extra-firmware.service --property=ExecMainExitTimestampMonotonic --value`,
                link,
            );

        const exitTimestampMicros = parseInt(exitTimestamp.trim(), 10) || 0;
        test.comment(`Attempt ${i}/${maxAttempts}: service exit timestamp = ${exitTimestampMicros}, threshold = ${timeBeforeMicros}`);

        if (exitTimestampMicros > timeBeforeMicros) {
            test.comment('Service was triggered automatically by config.json change');
            serviceTriggered = true;
            break;
        }
    }

    test.is(serviceTriggered, true, 'os-extra-firmware.service should be triggered automatically after config.json change');

    // Verify service is active
    const serviceStatus = await context
        .get()
        .worker.executeCommandInHostOS(
            `systemctl is-active os-extra-firmware.service || true`,
            link,
        );
    test.is(serviceStatus.trim(), 'active', 'os-extra-firmware.service should be active');
};

const verifySysfsPath = async (context, link, test) => {
    test.comment('Verifying firmware_class path in sysfs...');

    const expectedPath = `/var/lib/docker/volumes/${VOLUME_NAME}/_data`;

    // Check if sysfs path exists
    const sysfsExists = await context
        .get()
        .worker.executeCommandInHostOS(
            `test -f ${SYSFS_PATH} && echo exists || echo missing`,
            link,
        );

    if (sysfsExists.trim() !== 'exists') {
        test.comment(`WARNING: ${SYSFS_PATH} does not exist - kernel may not support runtime firmware path`);
        test.pass('Skipping sysfs check - path not available');
        return;
    }

    // Read the current firmware path
    const currentPath = await context
        .get()
        .worker.executeCommandInHostOS(
            `cat ${SYSFS_PATH}`,
            link,
        );

    test.is(currentPath.trim(), expectedPath, `Firmware path should be set to ${expectedPath}`);

    test.comment(`Firmware path correctly set: ${currentPath.trim()}`);
};

const verifyKernelCmdline = async (context, link, test) => {
    test.comment('Verifying firmware_class.path in kernel cmdline...');

    const expectedParam = `firmware_class.path=/var/lib/docker/volumes/${VOLUME_NAME}/_data`;

    const cmdline = await context
        .get()
        .worker.executeCommandInHostOS(
            `cat /proc/cmdline`,
            link,
        );

    const hasParam = cmdline.includes(expectedParam);
    test.is(hasParam, true, `Kernel cmdline should contain ${expectedParam}`);

    test.comment(`Kernel cmdline: ${cmdline.trim()}`);
};

const cleanup = async (context, link, test) => {
    test.comment('Cleaning up test environment...');

    // Restore original config.json
    await restoreConfig(context, link, test);

    // Remove the test volume
    await context
        .get()
        .worker.executeCommandInHostOS(
            `balena volume rm ${VOLUME_NAME} || true`,
            link,
        );

    // Restart service to clear the sysfs path
    await context
        .get()
        .worker.executeCommandInHostOS(
            `systemctl restart os-extra-firmware.service || true`,
            link,
        );

    test.comment('Cleanup complete');
};

module.exports = {
    title: 'Extra firmware test',
    run: async function(test) {
        // Backup config.json before making changes
        await backupConfig(this.context, this.link, test);

        // Step 1: Create a docker volume with test firmware
        await createTestVolume(this.context, this.link, test);

        // Step 2: Configure config.json and verify service is triggered automatically
        await configureExtraFirmwareAndVerifyServiceTriggered(this.context, this.link, test);

        // Step 3: Verify the sysfs path is set correctly
        await verifySysfsPath(this.context, this.link, test);

        // Step 4: Reboot to verify persistence
        test.comment('Rebooting devicz...');
        await this.context.get().worker.rebootDut(this.link);
        test.comment('Device rebooted successfully');

        // Step 5: Verify kernel cmdline has the firmware_class.path parameter
        await verifyKernelCmdline(this.context, this.link, test);

        // Step 6: Verify sysfs path is still set after reboot
        await verifySysfsPath(this.context, this.link, test);

        // Cleanup and restore config.json
        await cleanup(this.context, this.link, test);
    },
};

