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
const DOWNGRADE_FIRMWARE_DUT_PATH = `/mnt/data/${DOWNGRADE_FIRMWARE}`;
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
const runFlashromUpdate = async (
  context,
  link,
  test,
) => {
  const output = (await context
    .get()
    .worker.executeCommandInHostOS(
      `/usr/libexec/pieeprom-flashrom.sh 2>&1 || true`,
      link,
    )).trim();
  test.comment(`Flashrom output: ${output}`);
  test.ok(
    output.includes('SPI EEPROM fw update successful'),
    'Flashrom update should report success',
  );
  return output;
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
  await runFlashromUpdate(context, link, test);
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

const sendAndValidateDowngradeAsset = async (context, link, test) => {
  test.comment('Sending downgrade firmware asset to DUT...');
  await context
    .get()
    .worker.sendFile(DOWNGRADE_FIRMWARE_PATH, DOWNGRADE_FIRMWARE_DUT_PATH, link);

  const shippedVersion = await getFirmwareBuildTimestamp(context, link, EEPROM_IMAGE_PATH);
  const downgradeAssetVersion = await getFirmwareBuildTimestamp(
    context,
    link,
    DOWNGRADE_FIRMWARE_DUT_PATH,
  );
  test.comment(`Shipped firmware BUILD_TIMESTAMP: ${shippedVersion}`);
  test.comment(`Downgrade asset BUILD_TIMESTAMP: ${downgradeAssetVersion}`);
  test.ok(
    Number(downgradeAssetVersion) < Number(shippedVersion),
    'Downgrade firmware asset must be older than shipped EEPROM image',
  );
};

const backUpInitialBootloaderFirmware = async (context, link, test) => {
  test.comment(
    `Moving original ${EEPROM_IMAGE} and pieeprom.sig out of /mnt/boot (prevents self-update on reboot)...`,
  );
  await context
    .get()
    .worker.executeCommandInHostOS(
      `mv ${EEPROM_IMAGE_PATH} ${EEPROM_IMAGE_BACKUP_PATH} && mv ${EEPROM_SIG_PATH} ${EEPROM_SIG_BACKUP_PATH}`,
      link,
    );
};

const restoreInitialBootloaderFirmware = async (context, link) => {
  await context
    .get()
    .worker.executeCommandInHostOS(
      `mv ${EEPROM_IMAGE_BACKUP_PATH} ${EEPROM_IMAGE_PATH} && mv ${EEPROM_SIG_BACKUP_PATH} ${EEPROM_SIG_PATH}`,
      link,
    );
};

const deployDowngradeFirmware = async (context, link, test) => {
  await context
    .get()
    .worker.executeCommandInHostOS(
      `cp ${DOWNGRADE_FIRMWARE_DUT_PATH} ${EEPROM_IMAGE_PATH}`,
      link,
    );
  test.comment('Downgrade firmware deployed to /mnt/boot');
  const downgradeVersion = await getFirmwareBuildTimestamp(context, link, EEPROM_IMAGE_PATH);
  test.comment(`Downgrade firmware BUILD_TIMESTAMP: ${downgradeVersion}`);
  return downgradeVersion;
};

const prepareForDowngrade = async (context, link, test, worker) => {
  // Verify bootloader matches shipped image and
  // downgrade firmware is older than shipped firmware.
  await sendAndValidateDowngradeAsset(context, link, test);

  const initialVersion = await ensureBootloaderMatchesShippedImage(
    context,
    link,
    test,
    worker,
  );

  await backUpInitialBootloaderFirmware(context, link, test);
  const downgradeVersion = await deployDowngradeFirmware(context, link, test);
  test.ok(
    Number(downgradeVersion) < Number(initialVersion),
    'Downgrade firmware should be older than current bootloader',
  );

  return { initialVersion, downgradeVersion };
};

const verifyDowngradedBootloader = async (context, link, test, downgradeVersion) => {
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
};

const downgradeBootloader = async (context, link, test, worker) => {
  const { initialVersion, downgradeVersion } = await prepareForDowngrade(
    context,
    link,
    test,
    worker,
  );

  await runFlashromUpdate(context, link, test);

  test.comment('Rebooting to apply flashrom update...');
  await worker.rebootDut(link);

  await verifyDowngradedBootloader(context, link, test, downgradeVersion);

  return { initialVersion, downgradeVersion };
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


    test.comment('=== Test 1: Downgrade bootloader via flashrom ===');
    const { initialVersion } = await downgradeBootloader(
      context,
      link,
      test,
      this.worker,
    );

    test.comment('=== Test 2: Restore shipped firmware and verify self-update ===');
    await restoreInitialBootloaderFirmware(context, link);

    test.comment('Rebooting to trigger bootloader self-update...');
    await this.worker.rebootDut(link);

    const postSelfUpdateVersion = await getBootloaderVersion(context, link);
    test.comment(`Post-self-update bootloader version: ${postSelfUpdateVersion}`);
    test.is(
      postSelfUpdateVersion,
      initialVersion,
      'Bootloader version should match latest after self-update',
    );

    test.comment('=== Test 3: Verify bootloader_update=0 disables updates ===');
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
