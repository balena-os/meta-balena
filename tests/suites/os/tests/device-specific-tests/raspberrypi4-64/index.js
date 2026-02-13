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

'use strict';

const CONTAINER_NAME = 'eeprom-firmware';

// Get the bootloader timestamp from vcgencmd
const getBootloaderVersion = async (context, link) => {
  const output = await context
    .get()
    .worker.executeCommandInHostOS(
      `vcgencmd bootloader_version | grep timestamp | awk '{print $2}'`,
      link,
    );
  return output.trim();
};

// Resolve the volume mountpoint on the host for the eeprom-firmware named volume
const getFirmwareVolumePath = async (context, link) => {
  const path = await context
    .get()
    .worker.executeCommandInHostOS(
      `balena volume inspect $(balena volume ls -q --filter name=eeprom-firmware) --format '{{.Mountpoint}}'`,
      link,
    );
  return path.trim();
};

// Wait for the container to finish cloning firmware (poll for .done marker)
const waitForFirmwareReady = async (context, link, test, volumePath) => {
  test.comment('Waiting for firmware clone to complete...');
  let ready = false;
  for (let i = 0; i < 60; i++) {
    const out = await context
      .get()
      .worker.executeCommandInHostOS(
        `test -f ${volumePath}/.done && echo ready || echo waiting`,
        link,
      );
    if (out.trim() === 'ready') {
      ready = true;
      break;
    }
    await new Promise((r) => setTimeout(r, 10000));
  }
  test.is(ready, true, 'Firmware clone should complete within timeout');
};

// List firmware binaries sorted by name (oldest first), return array of full paths
const listFirmware = async (context, link, volumePath) => {
  const output = await context
    .get()
    .worker.executeCommandInHostOS(
      `ls -1 ${volumePath}/pieeprom-*.bin | sort`,
      link,
    );
  return output.trim().split('\n').filter((l) => l.length > 0);
};

// Deploy a firmware binary to /mnt/boot as pieeprom.bin + generate pieeprom.sig
const deployFirmwareToBootPartition = async (context, link, test, firmwarePath) => {
  test.comment(`Deploying firmware: ${firmwarePath}`);
  await context
    .get()
    .worker.executeCommandInHostOS(
      `cp ${firmwarePath} /mnt/boot/pieeprom.bin`,
      link,
    );
  // Generate the self-update signature (sha256 + timestamp)
  await context
    .get()
    .worker.executeCommandInHostOS(
      `sha256sum /mnt/boot/pieeprom.bin | awk '{print $1}' > /mnt/boot/pieeprom.sig && echo "ts: $(date -u +%s)" >> /mnt/boot/pieeprom.sig`,
      link,
    );
  // Verify files exist
  const exists = await context
    .get()
    .worker.executeCommandInHostOS(
      `test -f /mnt/boot/pieeprom.bin && test -f /mnt/boot/pieeprom.sig && echo ok || echo missing`,
      link,
    );
  test.is(exists.trim(), 'ok', 'pieeprom.bin and pieeprom.sig should exist on boot partition');
};

// Extract BUILD_TIMESTAMP from a firmware binary
const getFirmwareBuildTimestamp = async (context, link, firmwarePath) => {
  const output = await context
    .get()
    .worker.executeCommandInHostOS(
      `strings ${firmwarePath} | grep BUILD_TIMESTAMP | sed 's/.*=//'`,
      link,
    );
  return output.trim();
};

// Walk backwards from latest-1 to find a firmware whose BUILD_TIMESTAMP
// differs from the running bootloader version. Returns { path, version }.
const findDifferentFirmware = async (context, link, test, firmwareList, currentVersion) => {
  for (let i = firmwareList.length - 2; i >= 0; i--) {
    const candidate = firmwareList[i];
    const candidateVersion = await getFirmwareBuildTimestamp(context, link, candidate);
    test.comment(`Checking ${candidate}: BUILD_TIMESTAMP=${candidateVersion}`);
    if (candidateVersion !== currentVersion) {
      return { path: candidate, version: candidateVersion };
    }
  }
  return null;
};

// Force an EEPROM update via flashrom
const runForcedEepromUpdateViaFlashrom = async (context, link, image = 'pieeprom.bin') => {
  return (await context
    .get()
    .worker.executeCommandInHostOS(
      `/usr/libexec/pieeprom-flashrom.sh ${image} 2>&1 || true`,
      link,
    )).trim();
};

// Run the main EEPROM update script (decides self-update vs flashrom)
const runEepromUpdate = async (context, link) => {
  return (await context
    .get()
    .worker.executeCommandInHostOS(
      `/usr/libexec/pieeprom-update.sh 2>&1 || true`,
      link,
    )).trim();
};

module.exports = {
  deviceType: {
    type: 'object',
    required: ['slug'],
    properties: {
      slug: {
        type: 'string',
        enum: [
          'raspberrypi4-64',
          'raspberrypicm4-ioboard',
          'raspberrypicm4-ioboard-sb',
        ],
      },
    },
  },
  title: 'RPi4 EEPROM update (flashrom + self-update) test',
  run: async function (test) {
    const context = this.context;
    const link = this.link;

    // Step 0: Push firmware container and wait for clone
    test.comment('Pushing eeprom-firmware container to DUT...');
    const ip = await context.get().worker.ip(link);
    await context
      .get()
      .worker.pushContainerToDUT(ip, __dirname, CONTAINER_NAME);
    test.comment('Container pushed');

    const volumePath = await getFirmwareVolumePath(context, link);
    test.comment(`Firmware volume path: ${volumePath}`);
    await waitForFirmwareReady(context, link, test, volumePath);

    // List available firmware
    const firmwareList = await listFirmware(context, link, volumePath);
    test.comment(`Available firmware (${firmwareList.length} versions)`);
    test.ok(firmwareList.length >= 2, 'At least 2 firmware versions should be available');

    const latestFirmware = firmwareList[firmwareList.length - 1];
    test.comment(`Latest firmware: ${latestFirmware}`);

    // Record initial bootloader version
    const initialVersion = await getBootloaderVersion(context, link);
    test.comment(`Initial bootloader version: ${initialVersion}`);
    test.ok(Number(initialVersion) > 0, 'Initial bootloader version should be a valid timestamp');

    // Find a firmware with a different version than the running bootloader
    const flashromFirmware = await findDifferentFirmware(context, link, test, firmwareList, initialVersion);
    test.ok(flashromFirmware !== null, 'Should find a firmware version different from the running bootloader');
    test.comment(`Selected firmware for flashrom: ${flashromFirmware.path} (version ${flashromFirmware.version})`);

    // Step 1: Flashrom path - force update with previous firmware
    test.comment('=== Test 1: Forced flashrom update ===');
    await deployFirmwareToBootPartition(context, link, test, flashromFirmware.path);

    test.comment('Forcing EEPROM update via flashrom...');
    const flashromOutput = await runForcedEepromUpdateViaFlashrom(context, link);
    test.comment(`Script output: ${flashromOutput}`);
    test.ok(
      flashromOutput.includes('SPI EEPROM fw update successful'),
      'Script should log successful flashrom write',
    );

    test.comment('Rebooting to apply flashrom update...');
    await this.worker.rebootDut(link);

    const postFlashromVersion = await getBootloaderVersion(context, link);
    test.comment(`Post-flashrom bootloader version: ${postFlashromVersion}`);
    test.is(
      postFlashromVersion,
      flashromFirmware.version,
      'Bootloader version should match the firmware we flashed',
    );

    // Step 2: Self-update path - deploy latest firmware, let bootloader self-update
    test.comment('=== Test 2: Self-update mechanism ===');

    const latestFirmwareVersion = await getFirmwareBuildTimestamp(context, link, latestFirmware);
    test.comment(`Latest firmware BUILD_TIMESTAMP: ${latestFirmwareVersion}`);
    test.isNot(
      latestFirmwareVersion,
      postFlashromVersion,
      'Latest firmware version should differ from the currently flashed bootloader',
    );

    await deployFirmwareToBootPartition(context, link, test, latestFirmware);

    test.comment('Running pieeprom-update.sh (should detect self-update support)...');
    const selfUpdateOutput = await runEepromUpdate(context, link);
    test.comment(`Script output: ${selfUpdateOutput}`);
    test.ok(
      selfUpdateOutput.includes('Bootloader supports self-update'),
      'Script should detect self-update support and exit cleanly',
    );

    test.comment('Rebooting to trigger bootloader self-update...');
    await this.worker.rebootDut(link);

    const postSelfUpdateVersion = await getBootloaderVersion(context, link);
    test.comment(`Post-self-update bootloader version: ${postSelfUpdateVersion}`);
    test.is(
      postSelfUpdateVersion,
      latestFirmwareVersion,
      'Bootloader version should match the latest firmware after self-update',
    );

    // Step 3: Verify bootloader_update=0 disables all EEPROM updates
    test.comment('=== Test 3: bootloader_update=0 disables updates ===');
    await context
      .get()
      .worker.executeCommandInHostOS(
        `echo "bootloader_update=0" >> /mnt/boot/config.txt`,
        link,
      );
    const disabledOutput = await runEepromUpdate(context, link);
    test.comment(`Script output: ${disabledOutput}`);
    test.ok(
      disabledOutput.includes('EEPROM updates disabled in config.txt'),
      'Script should warn that updates are disabled via config.txt',
    );
    // Clean up: remove the line we added
    await context
      .get()
      .worker.executeCommandInHostOS(
        `sed -i '/^bootloader_update=0$/d' /mnt/boot/config.txt`,
        link,
      );

    test.comment('EEPROM update tests completed successfully');
  },
};
