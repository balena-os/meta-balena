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

const path = require('path');

const DOWNGRADE_FIRMWARE = 'pieeprom-2022-07-19.bin';
const DOWNGRADE_FIRMWARE_PATH = path.join(__dirname, 'assets', DOWNGRADE_FIRMWARE);
const EEPROM_IMAGE = 'pieeprom.upd';
const EEPROM_IMAGE_PATH = `/mnt/boot/${EEPROM_IMAGE}`;
const EEPROM_IMAGE_BACKUP_PATH = `/mnt/data/${EEPROM_IMAGE}.bak`;
const EEPROM_SIG_PATH = '/mnt/boot/pieeprom.sig';
const EEPROM_SIG_BACKUP_PATH = '/mnt/data/pieeprom.sig.bak';

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

// Run pieeprom-flashrom.sh directly (forces flashrom write, bypasses self-update check)
const runFlashromUpdate = async (context, link, image) => {
  return (await context
    .get()
    .worker.executeCommandInHostOS(
      `/usr/libexec/pieeprom-flashrom.sh ${image} 2>&1 || true`,
      link,
    )).trim();
};

const ensureBootloaderMatchesShippedImage = async (context, link, test, worker) => {
  const shippedVersion = await getFirmwareBuildTimestamp(context, link, EEPROM_IMAGE_PATH);
  const currentVersion = await getBootloaderVersion(context, link);
  test.comment(`Current bootloader version: ${currentVersion}`);
  test.comment(`Shipped firmware BUILD_TIMESTAMP: ${shippedVersion}`);

  if (currentVersion === shippedVersion) {
    test.comment('Bootloader already matches shipped image, skipping baseline flash');
    return currentVersion;
  }

  test.comment('Bootloader differs from shipped image, forcing flashrom update');
  const baselineFlashromOutput = await runFlashromUpdate(context, link, EEPROM_IMAGE);
  test.comment(`Baseline flash output: ${baselineFlashromOutput}`);
  test.ok(
    baselineFlashromOutput.includes('SPI EEPROM fw update successful') ||
      baselineFlashromOutput.includes('SPI EEPROM fw update is not necessary'),
    'Flashing current shipped EEPROM image should succeed or be already up-to-date',
  );
  test.comment('Rebooting after baseline flash...');
  await worker.rebootDut(link);

  const postBaselineVersion = await getBootloaderVersion(context, link);
  test.comment(`Post-baseline bootloader version: ${postBaselineVersion}`);
  test.is(
    postBaselineVersion,
    shippedVersion,
    `Bootloader version should match the EEPROM image currently shipped as ${EEPROM_IMAGE}`,
  );

  return postBaselineVersion;
};

// Run pieeprom-update.sh (orchestrator: self-update or flashrom)
const runEepromUpdate = async (context, link, image = EEPROM_IMAGE) => {
  return (await context
    .get()
    .worker.executeCommandInHostOS(
      `/usr/libexec/pieeprom-update.sh ${image} 2>&1 || true`,
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
        ],
      },
    },
  },
  title: 'RPi4 EEPROM update (flashrom + self-update) test',
  run: async function (test) {
    const context = this.context;
    const link = this.link;

    // Step 0: Ensure baseline only when current bootloader differs from shipped image.
    const initialVersion = await ensureBootloaderMatchesShippedImage(
      context,
      link,
      test,
      this.worker,
    );

    // Step 1: Move original firmware out of /mnt/boot, deploy downgrade as the active EEPROM image
    test.comment(`Moving original ${EEPROM_IMAGE} and pieeprom.sig out of /mnt/boot (prevents self-update on reboot)...`);
    await context
      .get()
      .worker.executeCommandInHostOS(
        `mv ${EEPROM_IMAGE_PATH} ${EEPROM_IMAGE_BACKUP_PATH} && mv ${EEPROM_SIG_PATH} ${EEPROM_SIG_BACKUP_PATH}`,
        link,
      );

    test.comment('Sending downgrade firmware to DUT...');
    await context
      .get()
      .worker.sendFile(DOWNGRADE_FIRMWARE_PATH, `/tmp/${DOWNGRADE_FIRMWARE}`, link);
    await context
      .get()
      .worker.executeCommandInHostOS(
        `mv /tmp/${DOWNGRADE_FIRMWARE} ${EEPROM_IMAGE_PATH}`,
        link,
      );
    test.comment('Firmware sent');

    const downgradeVersion = await getFirmwareBuildTimestamp(context, link, EEPROM_IMAGE_PATH);
    test.comment(`Downgrade firmware BUILD_TIMESTAMP: ${downgradeVersion}`);
    test.ok(
      Number(downgradeVersion) < Number(initialVersion),
      'Downgrade firmware should be older than current bootloader',
    );

    // Step 2: Downgrade via flashrom (pieeprom-flashrom.sh directly)
    test.comment('=== Test 2: Downgrade via flashrom ===');
    const flashromOutput = await runFlashromUpdate(context, link, EEPROM_IMAGE);
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
      downgradeVersion,
      'Bootloader version should match the downgrade firmware we flashed',
    );

    // Verify downgraded bootloader has ENABLE_SELF_UPDATE not disabled (same check as pieeprom-update.sh)
    const bootloaderConfig = await context
      .get()
      .worker.executeCommandInHostOS(`vcgencmd bootloader_config`, link);
    test.comment(`Bootloader config: ${bootloaderConfig.trim()}`);
    test.ok(
      !bootloaderConfig.includes('ENABLE_SELF_UPDATE=0'),
      'Downgraded bootloader EEPROM config should not have ENABLE_SELF_UPDATE=0',
    );

    // Step 3: Self-update path - restore original firmware and let bootloader self-update on reboot
    test.comment('=== Test 3: Self-update mechanism ===');

    // Restore original EEPROM image and pieeprom.sig for bootloader self-update
    await context
      .get()
      .worker.executeCommandInHostOS(
        `mv ${EEPROM_IMAGE_BACKUP_PATH} ${EEPROM_IMAGE_PATH} && mv ${EEPROM_SIG_BACKUP_PATH} ${EEPROM_SIG_PATH}`,
        link,
      );

    test.comment('Rebooting to trigger bootloader self-update...');
    await this.worker.rebootDut(link);

    const postSelfUpdateVersion = await getBootloaderVersion(context, link);
    test.comment(`Post-self-update bootloader version: ${postSelfUpdateVersion}`);
    test.is(
      postSelfUpdateVersion,
      initialVersion,
      'Bootloader version should match latest after self-update',
    );

    // Step 4: Verify bootloader_update=0 disables all EEPROM updates
    test.comment('=== Test 4: bootloader_update=0 disables updates ===');
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
