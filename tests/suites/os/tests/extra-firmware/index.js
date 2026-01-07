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

const VOLUME_NAME = 'extra-firmware';
const FIRMWARE_FILENAME = 'test_extra_firmware.bin';
const BUILD_CONTAINER_NAME = 'build';
const FIRMWARE_CONTAINER_NAME = 'extra-linux-firmware';
const MODULE_OUTPUT_VOLUME = 'module_output';
const SYSFS_PATH = '/sys/module/firmware_class/parameters/path';
const CONFIG_PATH = '/mnt/boot/config.json';
const CONFIG_BACKUP_PATH = '/mnt/state/config.json.extra-firmware-test-backup';

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
    await worker.executeCommandInHostOS('rmmod hello 2>/dev/null', link);
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
const getSysfsFirmwareClassValue = async (worker, link) => {
    const value = await worker.executeCommandInHostOS(
        `cat ${SYSFS_PATH} 2>/dev/null || echo ""`,
        link,
    );
    return value.trim();
};

/**
 * Get firmware directory from Docker volume mountpoint
 */
const getFirmwareDir = async (worker, link) => {
    const mountpoint = await worker.executeCommandInHostOS(
        `balena volume inspect ${VOLUME_NAME} | jq -r ".[].Mountpoint"`,
        link,
    );
    return mountpoint.trim();
};

/**
 * Check if secureboot is enabled based on FLASHER_SECUREBOOT environment variable
 */
const isSecureBootEnabled = () => {
    return ['1', 'true'].includes(process.env.FLASHER_SECUREBOOT);
};

// ============================================================================
// Test step functions
// ============================================================================

const buildTestModule = async (worker, link, test, suite) => {
    test.comment('Building test kernel module...');

    // Copy our hello.c and Makefile to kernel-module-build/module/src/ at runtime
    const srcDir = path.join(__dirname, 'src');
    const destDir = path.join(__dirname, 'kernel-module-build', 'module', 'src');

    test.comment('Copying firmware test module sources...');
    await fse.copy(path.join(srcDir, 'hello.c'), path.join(destDir, 'hello.c'));
    await fse.copy(path.join(srcDir, 'Makefile'), path.join(destDir, 'Makefile'));

    // Check if kernel headers archive exists and copy it
    const kernelHeadersPath = suite.context.get().os.kernelHeaders;
    const headersExists = await fse.pathExists(kernelHeadersPath);

    test.is(headersExists, true, 'Kernel headers archive should be provided in workspace/config.js');

    await fse.copy(kernelHeadersPath, path.join(__dirname, 'kernel-module-build', 'module', path.basename(kernelHeadersPath)));

    test.comment('Pushing build container to device...');
    await worker.pushContainerToDUT(link, __dirname, BUILD_CONTAINER_NAME);
};

const verifyFirmware = async (worker, link, test) => {
    test.comment('Verifying firmware file...');
    const firmwareDir = await getFirmwareDir(worker, link);
    const firmwarePath = `${firmwareDir}/${FIRMWARE_FILENAME}`;

    test.is(firmwareDir !== '', true, 'firmwareDir path should not be empty');
    test.comment(`Firmware path: ${firmwarePath}`);

    const fileExists = await worker.executeCommandInHostOS(
        `test -f ${firmwarePath} && echo "exists" || echo "missing"`,
        link,
    );

    test.is(fileExists.trim(), 'exists', 'Firmware file should exist');
    const content = await worker.executeCommandInHostOS(
        `cat ${firmwarePath}`,
        link,
    );
    test.is(content.trim(), 'balena', 'Firmware file should contain magic string');
};

/**
 * Verify firmware container state: volume exists, config.json is set, service has run
 */
const verifyFirmwareContainerState = async (worker, link, test) => {
    test.comment('Verifying firmware container state...');

    // Check that volume exists
    const firmwareDir = await getFirmwareDir(worker, link);
    test.is(firmwareDir !== '', true, 'Firmware volume should exist');
    test.comment(`Firmware directory: "${firmwareDir}"`);

    // Check config.json has extraFirmwareVol set
    const configValue = await getConfigExtraFirmwareVol(worker, link);
    test.is(configValue, VOLUME_NAME, 'config.json should contain the correct volume name');
    test.comment(`config.json extraFirmwareVol: "${configValue}"`);

    // Check that service has run successfully
    const result = await worker.executeCommandInHostOS(
        `systemctl show os-extra-firmware.service --property=Result --value`,
        link,
    );
    test.is(result.trim(), 'success', 'os-extra-firmware.service should have run successfully');

    // Verify sysfs path is set
    await verifySysfsPath(worker, link, test);
};

/**
 * Test that firmware loading fails without extra-firmware container
 */
const testFirmwareNotFound = async (worker, link, test) => {
    test.comment('Loading module without firmware container (expect NOT FOUND)...');

    const modulePath = await getModulePath(worker, link);
    test.comment(`Module path: ${modulePath}`);
    test.is(modulePath !== '', true, 'Module path should not be empty');

    const dmesg = await loadModuleAndGetDmesg(worker, link, modulePath);
    test.comment(`dmesg: ${dmesg}`);
    test.is(dmesg.includes('NOT FOUND'), true, 'Firmware should NOT be found');
};

/**
 * Test that firmware loading succeeds with configuration
 */
const testFirmwareFound = async (worker, link, test) => {
    test.comment('Loading module with firmware (expect SUCCESS)...');

    const modulePath = await getModulePath(worker, link);
    test.comment(`Module path: ${modulePath}`);
    test.is(modulePath !== '', true, 'Module path should not be empty');

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

    const firmwareDir = await getFirmwareDir(worker, link);
    const expectedParam = `firmware_class.path=${firmwareDir}`;

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

    const expectedPath = await getFirmwareDir(worker, link);
    const sysfsValue = await getSysfsFirmwareClassValue(worker, link);
    test.comment(`sysfs firmware path: "${sysfsValue}"`);
    test.is(sysfsValue, expectedPath, 'sysfs firmware path should be configured');
};

/**
 * Cleanup
 */
const cleanup = async (worker, link, test) => {
    test.comment('Cleaning up...');

    // Restore config.json
    await restoreConfig(worker, link, test);

    // Remove module from device
    await worker.executeCommandInHostOS('rmmod hello 2>/dev/null || true', link);

    // Remove containers and volumes
    await worker.executeCommandInHostOS(
        `balena rm -f $(balena ps -aqf name=${BUILD_CONTAINER_NAME}) 2>/dev/null || true`,
        link,
    );
    await worker.executeCommandInHostOS(
        `balena rm -f $(balena ps -aqf name=${FIRMWARE_CONTAINER_NAME}) 2>/dev/null || true`,
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

        // Skip test if secureboot is enabled
        if (isSecureBootEnabled()) {
            test.comment('Skipping extra-firmware test on secureboot-enabled device');
            return;
        }

        try {
            // Backup config.json
            await backupConfig(worker, link, test);

            // Step 1: Build test module
            await buildTestModule(worker, link, test, this.suite);

            // Step 2: Test that firmware is NOT found before deploying firmware container
            await testFirmwareNotFound(worker, link, test);

            // Step 3: Deploy firmware container
            test.comment('Pushing firmware container to device...');
            const firmwareContainerPath = path.join(__dirname, 'firmware-container');
            await worker.pushContainerToDUT(link, firmwareContainerPath, FIRMWARE_CONTAINER_NAME);

            // Step 4: Verify firmware container state (volume, config.json, service)
            await verifyFirmwareContainerState(worker, link, test);

            // Step 5: Verify the firmware file
            await verifyFirmware(worker, link, test);

            // Step 6: Load module - expect firmware FOUND and VERIFIED
            await testFirmwareFound(worker, link, test);

            if (this.suite.deviceType.slug == 'srd3-xavier') {
                test.comment('Skipping extra-firmware post-reboot test on Jetpack 4 Xavier AGX');
                return;
            }

            // Step 7: Reboot
            await worker.rebootDut(link);

            // Step 8: Verify kernel cmdline has firmware_class.path
            await verifyKernelCmdline(worker, link, test);

            // Step 9: Verify sysfs path is still set
            await verifySysfsPath(worker, link, test);

            // Step 10: Load module again - should still work after reboot
            await testFirmwareFound(worker, link, test);
        } finally {
            await cleanup(worker, link, test);
        }
    },
};
