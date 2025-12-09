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

const fse = require('fs-extra');
const path = require('path');

const VOLUME_NAME = 'test_extra_firmware';
const FIRMWARE_FILENAME = 'test_extra_firmware.bin';
const BUILD_CONTAINER_NAME = 'build';
const MODULE_OUTPUT_VOLUME = 'module_output';
const SYSFS_PATH = '/sys/module/firmware_class/parameters/path';
const CONFIG_PATH = '/mnt/boot/config.json';
const CONFIG_BACKUP_PATH = '/mnt/state/config.json.extra-firmware-test-backup';
const FIRMWARE_DIR = `/var/lib/docker/volumes/${VOLUME_NAME}/_data`;

// ============================================================================
// Helper functions
// ============================================================================

const backupConfig = async (worker, link, test) => {
    test.comment('Backing up config.json...');
    await worker.executeCommandInHostOS(
        `cp ${CONFIG_PATH} ${CONFIG_BACKUP_PATH}`,
        link,
    );
};

const restoreConfig = async (worker, link, test) => {
    test.comment('Restoring config.json...');
    await worker.executeCommandInHostOS(
        `test -f ${CONFIG_BACKUP_PATH} && mv ${CONFIG_BACKUP_PATH} ${CONFIG_PATH} || true`,
        link,
    );
};

/**
 * Get the module path from the output volume
 */
const getModulePath = async (worker, link) => {
    const modulePath = await worker.executeCommandInHostOS(
        `ls /var/lib/docker/volumes/*${MODULE_OUTPUT_VOLUME}*/_data/*.ko 2>/dev/null | head -1`,
        link,
    );
    return modulePath.trim();
};

/**
 * Load module, check dmesg, unload. Returns dmesg output.
 */
const loadModuleAndGetDmesg = async (worker, link, modulePath) => {
    await worker.executeCommandInHostOS('dmesg -C', link);
    await worker.executeCommandInHostOS('rmmod hello 2>/dev/null || true', link);
    await worker.executeCommandInHostOS(`insmod ${modulePath}`, link);
    const dmesg = await worker.executeCommandInHostOS('dmesg | grep "hello:" || true', link);
    await worker.executeCommandInHostOS('rmmod hello 2>/dev/null || true', link);
    return dmesg.trim();
};

/**
 * Check if config.json has extraFirmwareVol set
 */
const getConfigExtraFirmwareVol = async (worker, link) => {
    const value = await worker.executeCommandInHostOS(
        `jq -r '.os.kernel.extraFirmwareVol // empty' ${CONFIG_PATH}`,
        link,
    );
    return value.trim();
};

/**
 * Check the current sysfs firmware path
 */
const getSysfsPath = async (worker, link) => {
    const value = await worker.executeCommandInHostOS(
        `cat ${SYSFS_PATH} 2>/dev/null || echo ""`,
        link,
    );
    return value.trim();
};

// ============================================================================
// Test step functions
// ============================================================================

/**
 * Build the kernel module
 */
const buildKernelModule = async (worker, link, test) => {
    test.comment('Building test kernel module...');

    // Copy our hello.c and Makefile to kernel-module-build/module/src/ at runtime
    const srcDir = path.join(__dirname, 'src');
    const destDir = path.join(__dirname, 'kernel-module-build', 'module', 'src');
    
    test.comment('Copying firmware test module sources...');
    await fse.copy(path.join(srcDir, 'hello.c'), path.join(destDir, 'hello.c'));
    await fse.copy(path.join(srcDir, 'Makefile'), path.join(destDir, 'Makefile'));

    // Get OS version from device
    const osVersion = await worker.executeCommandInHostOS(
        `cat /etc/os-release | grep VERSION_ID | cut -d= -f2 | tr -d '"'`,
        link,
    );
    test.comment(`OS Version: ${osVersion.trim()}`);

    // Update OS_VERSION in our docker-compose.yml
    const dockerComposePath = path.join(__dirname, 'docker-compose.yml');
    const data = await fse.readFile(dockerComposePath, 'utf-8');
    const updatedData = data.replace(/OS_VERSION:\s*\S+/, `OS_VERSION: ${osVersion.trim()}`);
    await fse.writeFile(dockerComposePath, updatedData, 'utf-8');

    // Build and run container
    test.comment('Building kernel module container on device...');
    await worker.pushContainerToDUT(link, __dirname, BUILD_CONTAINER_NAME);
};

/**
 * Verify initial state: config.json and sysfs path should be empty/unset
 */
const verifyInitialState = async (worker, link, test) => {
    test.comment('Verifying initial state (no extra firmware configured)...');

    const configValue = await getConfigExtraFirmwareVol(worker, link);
    test.comment(`config.json extraFirmwareVol: "${configValue}"`);
    test.is(configValue, '', 'extraFirmwareVol should not be set initially');

    const sysfsValue = await getSysfsPath(worker, link);
    test.comment(`sysfs firmware path: "${sysfsValue}"`);
    test.is(sysfsValue, '', 'sysfs firmware path should be empty initially');
};

/**
 * Test that firmware loading fails without configuration
 */
const testFirmwareNotFound = async (worker, link, test, modulePath) => {
    test.comment('Loading module without firmware (expect NOT FOUND)...');
    const dmesg = await loadModuleAndGetDmesg(worker, link, modulePath);
    test.comment(`dmesg: ${dmesg}`);
    test.is(dmesg.includes('NOT FOUND'), true, 'Firmware should NOT be found');
};

/**
 * Configure config.json with extraFirmwareVol and wait for service
 */
const configureExtraFirmware = async (worker, link, test) => {
    test.comment('Configuring os.kernel.extraFirmwareVol in config.json...');

    // Get monotonic time before config change
    const monotonicTimeBefore = await worker.executeCommandInHostOS(
        `cat /proc/uptime | awk '{printf "%.0f", $1 * 1000000}'`,
        link,
    );

    // Update config.json
    await worker.executeCommandInHostOS(
        `jq '.os.kernel.extraFirmwareVol = "${VOLUME_NAME}"' ${CONFIG_PATH} > /tmp/config.json && cp /tmp/config.json ${CONFIG_PATH}`,
        link,
    );

    // Verify config was set
    const configValue = await getConfigExtraFirmwareVol(worker, link);
    test.is(configValue, VOLUME_NAME, 'config.json should have extraFirmwareVol set');

    // Wait for service to be triggered
    test.comment('Waiting for os-extra-firmware.service to be triggered...');
    const maxAttempts = 10;
    let serviceTriggered = false;
    const timeBeforeMicros = parseInt(monotonicTimeBefore.trim(), 10);

    for (let i = 1; i <= maxAttempts; i++) {
        await new Promise(r => setTimeout(r, 1000));

        const exitTimestamp = await worker.executeCommandInHostOS(
            `systemctl show os-extra-firmware.service --property=ExecMainExitTimestampMonotonic --value`,
            link,
        );

        const exitTimestampMicros = parseInt(exitTimestamp.trim(), 10) || 0;
        if (exitTimestampMicros > timeBeforeMicros) {
            test.comment(`Service triggered after ${i}s`);
            serviceTriggered = true;
            break;
        }
    }

    test.is(serviceTriggered, true, 'os-extra-firmware.service should be triggered');

    // Verify sysfs path is set
    const sysfsValue = await getSysfsPath(worker, link);
    test.comment(`sysfs firmware path: "${sysfsValue}"`);
    test.is(sysfsValue, FIRMWARE_DIR, 'sysfs firmware path should be configured');
};

/**
 * Create the Docker volume (must exist before configuring config.json)
 */
const createVolume = async (worker, link, test) => {
    test.comment('Creating Docker volume...');

    await worker.executeCommandInHostOS(
        `balena volume create ${VOLUME_NAME}`,
        link,
    );

    const volumeExists = await worker.executeCommandInHostOS(
        `balena volume inspect ${VOLUME_NAME} >/dev/null 2>&1 && echo exists || echo missing`,
        link,
    );
    test.is(volumeExists.trim(), 'exists', `Docker volume ${VOLUME_NAME} should exist`);
};

/**
 * Create the firmware file in the volume
 */
const createFirmwareFile = async (worker, link, test) => {
    test.comment('Creating firmware file...');

    const firmwarePath = `${FIRMWARE_DIR}/${FIRMWARE_FILENAME}`;
    
    await worker.executeCommandInHostOS(
        `echo -n "balena" > ${firmwarePath}`,
        link,
    );

    const content = await worker.executeCommandInHostOS(
        `cat ${firmwarePath}`,
        link,
    );
    test.comment(`Firmware file content: "${content.trim()}"`);
    test.is(content.trim(), 'balena', 'Firmware file should contain magic string');
};

/**
 * Test that firmware loading succeeds with configuration
 */
const testFirmwareFound = async (worker, link, test, modulePath) => {
    test.comment('Loading module with firmware (expect SUCCESS)...');
    const dmesg = await loadModuleAndGetDmesg(worker, link, modulePath);
    test.comment(`dmesg: ${dmesg}`);
    test.is(dmesg.includes('SUCCESS'), true, 'Firmware should be found');
    test.is(dmesg.includes('VERIFIED'), true, 'Firmware content should be verified');
};

/**
 * Verify kernel cmdline has firmware_class.path after reboot
 */
const verifyKernelCmdline = async (worker, link, test) => {
    test.comment('Verifying firmware_class.path in kernel cmdline...');

    const expectedParam = `firmware_class.path=${FIRMWARE_DIR}`;

    const cmdline = await worker.executeCommandInHostOS(
        `cat /proc/cmdline`,
        link,
    );

    test.comment(`Kernel cmdline: ${cmdline.trim()}`);
    test.is(cmdline.includes(expectedParam), true, `Kernel cmdline should contain ${expectedParam}`);
};

/**
 * Verify sysfs path is set correctly
 */
const verifySysfsPath = async (worker, link, test) => {
    test.comment('Verifying sysfs firmware path...');

    const sysfsValue = await getSysfsPath(worker, link);
    test.comment(`sysfs firmware path: "${sysfsValue}"`);
    test.is(sysfsValue, FIRMWARE_DIR, 'sysfs firmware path should be configured');
};

/**
 * Cleanup
 */
const cleanup = async (worker, link, test) => {
    test.comment('Cleaning up...');

    // Restore config.json
    await restoreConfig(worker, link, test);

    // Remove containers and volumes
    await worker.executeCommandInHostOS(
        `balena rm -f $(balena ps -aqf NAME=${BUILD_CONTAINER_NAME}) 2>/dev/null || true`,
        link,
    );
    await worker.executeCommandInHostOS(
        `balena volume rm ${MODULE_OUTPUT_VOLUME} 2>/dev/null || true`,
        link,
    );
    await worker.executeCommandInHostOS(
        `balena volume rm ${VOLUME_NAME} 2>/dev/null || true`,
        link,
    );

    // Restart service to clear sysfs path
    await worker.executeCommandInHostOS(
        `systemctl restart os-extra-firmware.service || true`,
        link,
    );

    test.comment('Cleanup complete');
};

// ============================================================================
// Main test
// ============================================================================

module.exports = {
    title: 'Extra firmware test',
    run: async function(test) {
        const worker = this.context.get().worker;
        const link = this.link;

        try {
            // Backup config.json
            await backupConfig(worker, link, test);

            // Step 1: Build kernel module
            await buildKernelModule(worker, link, test);
            const modulePath = await getModulePath(worker, link);
            test.comment(`Module path: ${modulePath}`);
            test.is(modulePath !== '', true, 'Module path should not be empty');

            // Step 2: Verify initial state (config and sysfs should be empty)
            await verifyInitialState(worker, link, test);

            // Step 3: Try to load module - expect firmware NOT FOUND
            await testFirmwareNotFound(worker, link, test, modulePath);

            // Step 4: Create Docker volume (must exist before configuring config.json)
            await createVolume(worker, link, test);

            // Step 5: Configure config.json with extraFirmwareVol
            // The os-extra-firmware service needs the volume to exist to get its mountpoint
            await configureExtraFirmware(worker, link, test);

            // Step 6: Create firmware file in the volume
            await createFirmwareFile(worker, link, test);

            // Step 7: Load module - expect firmware FOUND and VERIFIED
            await testFirmwareFound(worker, link, test, modulePath);

            // Step 8: Reboot
            test.comment('Rebooting device...');
            await worker.rebootDut(link);
            test.comment('Device rebooted');

            // Step 9: Verify kernel cmdline has firmware_class.path
            await verifyKernelCmdline(worker, link, test);

            // Step 10: Verify sysfs path is still set
            await verifySysfsPath(worker, link, test);

            // Step 11: Load module again - should still work after reboot
            await testFirmwareFound(worker, link, test, modulePath);
        } finally {
            await cleanup(worker, link, test);
        }
    },
};
