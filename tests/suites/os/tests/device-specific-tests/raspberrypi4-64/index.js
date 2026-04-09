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

// The downgrade firmware is comming from github.com/raspberrypi/rpi-eeprom.git
// It's a working version with SELF_UPDATE enabled that can be used to downgrade the bootloader.
const DOWNGRADE_FIRMWARE = 'pieeprom-2022-07-19.bin';
const DOWNGRADE_FIRMWARE_MD5 = '3bc921f60a573f5a601cefbcb1685bf4';
const DOWNGRADE_FIRMWARE_PATH = path.join(__dirname, 'assets', DOWNGRADE_FIRMWARE);
const DOWNGRADE_FIRMWARE_DUT_PATH = `/mnt/data/${DOWNGRADE_FIRMWARE}`;
const EEPROM_IMAGE = 'pieeprom.upd';
const EEPROM_IMAGE_PATH = `/mnt/boot/${EEPROM_IMAGE}`;
const EEPROM_IMAGE_BACKUP_PATH = `/mnt/data/${EEPROM_IMAGE}.bak`;
const EEPROM_SIG_PATH = '/mnt/boot/pieeprom.sig';
const EEPROM_SIG_BACKUP_PATH = '/mnt/data/pieeprom.sig.bak';
const CONFIG_TXT_PATH = '/mnt/boot/config.txt';
const CONFIG_TXT_BACKUP_PATH = '/mnt/data/config.txt.bak';
const UPDATES_DISABLED_MESSAGE = 'EEPROM updates disabled in config.txt';

// Set in testSetup; read after teardown to verify boot files match the shipped binaries.
let shippedEepromUpdMd5 = null;
let shippedEepromSigMd5 = null;

const runCommandWithExitCode = async (context, link, command) => {
  const rawOutput = await context
    .get()
    .worker.executeCommandInHostOS(
      `${command} 2>&1; echo $?`,
      link,
    );
  const lines = rawOutput.trim().split('\n');
  const exitCode = Number(lines.pop());
  return {
    output: lines.join('\n').trim(),
    exitCode,
  };
};

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

const getFileMd5 = async (context, link, filePath) => {
  const output = await context
    .get()
    .worker.executeCommandInHostOS(
      `md5sum ${filePath} | awk '{print $1}'`,
      link,
    );
  return output.trim();
};

const validateTimestamp = (test, value, label) => {
  test.ok(/^\d+$/.test(value), `${label} should be a numeric unix timestamp`);
  test.ok(Number(value) > 0, `${label} should be greater than 0`);
};

// Run pieeprom-flashrom.sh directly (forces flashrom write, bypasses self-update check)
const runFlashromUpdate = async (
  context,
  link,
  test,
) => {
  const { output, exitCode } = await runCommandWithExitCode(
    context,
    link,
    '/usr/libexec/pieeprom-flashrom.sh',
  );
  test.comment(`Flashrom output: ${output}`);
  test.ok(
    exitCode === 0,
    exitCode === 0
      ? 'Flashrom update exited with code 0'
      : `Flashrom update failed with exit code ${exitCode}; EEPROM may be in an inconsistent state, exit code 2 might be safe after a reboot`,
  );
  test.ok(
    output.includes('SPI EEPROM fw update successful'),
    'Flashrom update should report success',
  );
  return { output, exitCode };
};

// Run pieeprom-update.sh (orchestrator: self-update or flashrom)
const runEepromUpdate = async (context, link, image = EEPROM_IMAGE) => {
  return runCommandWithExitCode(
    context,
    link,
    `/usr/libexec/pieeprom-update.sh ${image}`,
  );
};

// Send the downgrade EEPROM fixture to the DUT, validate its checksum, and
// return its BUILD_TIMESTAMP for setup-level assertions.
const sendAndValidateDowngradeAsset = async (context, link, test) => {
  test.comment('Sending downgrade firmware asset to DUT...');
  await context
    .get()
    .worker.sendFile(DOWNGRADE_FIRMWARE_PATH, DOWNGRADE_FIRMWARE_DUT_PATH, link);

  const downgradeAssetMd5 = await context
    .get()
    .worker.executeCommandInHostOS(
      `md5sum ${DOWNGRADE_FIRMWARE_DUT_PATH} | awk '{print $1}'`,
      link,
    );
  test.comment(`Downgrade asset md5sum on DUT: ${downgradeAssetMd5.trim()}`);
  test.is(
    downgradeAssetMd5.trim(),
    DOWNGRADE_FIRMWARE_MD5,
    'Downgrade firmware md5sum on DUT should match expected fixture checksum',
  );

  const downgradeAssetVersion = await getFirmwareBuildTimestamp(
    context,
    link,
    DOWNGRADE_FIRMWARE_DUT_PATH,
  );
  test.comment(`Downgrade asset BUILD_TIMESTAMP: ${downgradeAssetVersion}`);
  validateTimestamp(test, downgradeAssetVersion, 'Downgrade firmware BUILD_TIMESTAMP');
  return downgradeAssetVersion;
};

// Setup phase for this test:
// 1) send downgrade eeprom fixture to DUT and verify its md5/timestamp integrity
// 2) verify version invariants (downgrade < shipped, running == shipped)
const testSetup = async (context, link, test) => {
  test.comment('Running EEPROM setup checks...');

  const shippedVersion = await getFirmwareBuildTimestamp(context, link, EEPROM_IMAGE_PATH);
  validateTimestamp(test, shippedVersion, 'Shipped firmware BUILD_TIMESTAMP');
  test.comment(`shipped firmware BUILD_TIMESTAMP: ${shippedVersion}`);

  const currentVersion = await getBootloaderVersion(context, link);
  test.comment(`current bootloader version: ${currentVersion}`);
  validateTimestamp(test, currentVersion, 'Current bootloader version');
  test.is(
    currentVersion,
    shippedVersion,
    'Running bootloader version should match shipped EEPROM image',
  );

  const downgradeAssetVersion = await sendAndValidateDowngradeAsset(
    context,
    link,
    test,
  );
  test.comment(`sent downgrade firmware BUILD_TIMESTAMP: ${downgradeAssetVersion}`);
  test.ok(
    Number(downgradeAssetVersion) < Number(shippedVersion),
    'Sent downgrade firmware should be older than shipped EEPROM image',
  );

  shippedEepromUpdMd5 = await getFileMd5(context, link, EEPROM_IMAGE_PATH);
  shippedEepromSigMd5 = await getFileMd5(context, link, EEPROM_SIG_PATH);

  return currentVersion;
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
      `cp ${EEPROM_IMAGE_BACKUP_PATH} ${EEPROM_IMAGE_PATH} && cp ${EEPROM_SIG_BACKUP_PATH} ${EEPROM_SIG_PATH}`,
      link,
    );
};

const restoreInitialBootloaderFirmwareInTeardown = async (context, link) => {
  await context
    .get()
    .worker.executeCommandInHostOS(
      `if [ -f ${EEPROM_IMAGE_BACKUP_PATH} ]; then mv -f ${EEPROM_IMAGE_BACKUP_PATH} ${EEPROM_IMAGE_PATH}; fi`,
      link,
    );
  await context
    .get()
    .worker.executeCommandInHostOS(
      `if [ -f ${EEPROM_SIG_BACKUP_PATH} ]; then mv -f ${EEPROM_SIG_BACKUP_PATH} ${EEPROM_SIG_PATH}; fi`,
      link,
    );
};

const backUpConfigTxt = async (context, link, test) => {
  test.comment('Backing up config.txt before test modifications...');
  await context
    .get()
    .worker.executeCommandInHostOS(
      `cp ${CONFIG_TXT_PATH} ${CONFIG_TXT_BACKUP_PATH}`,
      link,
    );
};

const restoreConfigTxt = async (context, link) => {
  await context
    .get()
    .worker.executeCommandInHostOS(
      `if [ -f ${CONFIG_TXT_BACKUP_PATH} ]; then mv -f ${CONFIG_TXT_BACKUP_PATH} ${CONFIG_TXT_PATH}; fi`,
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

const prepareForDowngrade = async (context, link, test, initialVersion) => {
  const downgradeVersion = await deployDowngradeFirmware(context, link, test);
  test.ok(
    Number(downgradeVersion) < Number(initialVersion),
    'Downgrade firmware should be older than current bootloader',
  );

  return downgradeVersion;
};

const verifyDowngradedBootloader = async (context, link, test, downgradeVersion) => {
  const postFlashromVersion = await getBootloaderVersion(context, link);
  test.comment(`Post-flashrom bootloader version: ${postFlashromVersion}`);
  test.is(
    postFlashromVersion,
    downgradeVersion,
    'Bootloader version should match the downgrade firmware flashed',
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

const downgradeBootloader = async (context, link, test, worker, initialVersion) => {
  await backUpInitialBootloaderFirmware(context, link, test);

  const downgradeVersion = await prepareForDowngrade(
    context,
    link,
    test,
    initialVersion,
  );

  await runFlashromUpdate(context, link, test);

  test.comment('Rebooting to apply flashrom update...');
  await worker.rebootDut(link);

  await verifyDowngradedBootloader(context, link, test, downgradeVersion);

};

const bestEffortTearDown = async (
  context,
  link,
  test,
  needTearDownFlashrom,
  initialVersion,
) => {
  test.comment('=== Teardown: best-effort restore of EEPROM/config state ===');

  try {
    await restoreConfigTxt(context, link);
  } catch (error) {
    test.comment(`Teardown warning: failed to restore config.txt (${error.message})`);
  }

  try {
    await restoreInitialBootloaderFirmwareInTeardown(context, link);
  } catch (error) {
    test.comment(`Teardown warning: failed to restore EEPROM backup files (${error.message})`);
  }

  if (needTearDownFlashrom) {
    test.comment('Teardown: self-update failed, forcing flashrom recovery');
    try {
      await runFlashromUpdate(context, link, test);
      test.comment('Teardown: rebooting after flashrom recovery');
      await context
        .get()
        .worker.rebootDut(link);
    } catch (error) {
      test.comment(`Teardown warning: flashrom recovery failed (${error.message})`);
    }
  }
  await verifyTeardownEepromMd5(context, link, test);
  await verifyTeardownEepromVersion(context, link, test, initialVersion);
};

const verifyTeardownEepromMd5 = async (context, link, test) => {
  if (!shippedEepromUpdMd5 || !shippedEepromSigMd5) {
    test.comment('Post-teardown EEPROM md5 check skipped (setup did not complete baseline capture)');
    return;
  }
  test.comment('=== Post-teardown: verify boot partition EEPROM files match setup baseline ===');
  try {
    const finalEepromMd5 = await getFileMd5(context, link, EEPROM_IMAGE_PATH);
    const finalSigMd5 = await getFileMd5(context, link, EEPROM_SIG_PATH);
    test.is(
      finalEepromMd5,
      shippedEepromUpdMd5,
      `After teardown, ${EEPROM_IMAGE} md5 should match setup baseline`,
    );
    test.is(
      finalSigMd5,
      shippedEepromSigMd5,
      'After teardown, pieeprom.sig md5 should match setup baseline',
    );
  } catch (error) {
    test.comment(`Post-teardown EEPROM md5 verification failed (${error.message})`);
  }
};

const verifyTeardownEepromVersion = async (context, link, test, initialVersion) => {
  if (!initialVersion) {
    test.comment('Post-teardown bootloader version check skipped (no baseline version)');
    return;
  }
  test.comment('=== Post-teardown: verify running bootloader matches setup baseline ===');
  try {
    const finalBootloaderVersion = await getBootloaderVersion(context, link);
    test.comment(`Post-teardown bootloader version: ${finalBootloaderVersion}`);
    test.is(
      finalBootloaderVersion,
      initialVersion,
      'After teardown, running bootloader should match setup baseline version',
    );
  } catch (error) {
    test.comment(`Post-teardown bootloader version verification failed (${error.message})`);
  }
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
    let needTearDownFlashrom = false;
    let initialVersion = null;

    try {
      initialVersion = await testSetup(context, link, test);

      test.comment('=== Test 1: Downgrade bootloader via flashrom ===');

      await downgradeBootloader(
        context,
        link,
        test,
        this.worker,
        initialVersion,
      );

      test.comment('=== Test 2: Restore shipped firmware and verify self-update ===');
      await restoreInitialBootloaderFirmware(context, link);

      test.comment('Rebooting to trigger bootloader self-update...');
      needTearDownFlashrom = true;
      await this.worker.rebootDut(link);

      const postSelfUpdateVersion = await getBootloaderVersion(context, link);
      test.comment(`Post-self-update bootloader version: ${postSelfUpdateVersion}`);
      test.is(
        postSelfUpdateVersion,
        initialVersion,
        'Bootloader version should match latest after self-update',
      );
      needTearDownFlashrom = false;

      test.comment('=== Test 3: Verify bootloader_update=0 disables updates ===');
      await backUpConfigTxt(context, link, test);
      await context
        .get()
        .worker.executeCommandInHostOS(
          `echo "bootloader_update=0" >> ${CONFIG_TXT_PATH}`,
          link,
        );
      const { output: disabledOutput, exitCode: disabledExitCode } = await runEepromUpdate(
        context,
        link,
      );
      test.comment(`Script output: ${disabledOutput}`);
      test.is(
        disabledExitCode,
        0,
        `Script should exit successfully when bootloader updates are disabled (got ${disabledExitCode})`,
      );
      test.ok(
        disabledOutput.includes(UPDATES_DISABLED_MESSAGE),
        'Script should warn that updates are disabled via config.txt',
      );

      await restoreConfigTxt(context, link);

      test.comment('EEPROM update tests completed successfully');
    } finally {
      await bestEffortTearDown(
        context,
        link,
        test,
        needTearDownFlashrom,
        initialVersion
      );
    }
  },
};
