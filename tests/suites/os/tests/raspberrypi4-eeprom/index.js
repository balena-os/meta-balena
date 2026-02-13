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

const fs = require('fs-extra');
const os = require('os');
const path = require('path');
const {
	prepareSecureBootDowngradeAssets,
	SB_EXPECTED_MD5,
	prepareNonSecureBootDowngradeAssets,
	NON_SB_EXPECTED_MD5,
} = require('./rpieeprom-assets');

const EEPROM_IMAGE_PATH = '/mnt/boot/pieeprom.upd';
const EEPROM_SIG_PATH = '/mnt/boot/pieeprom.sig';
const BOOT_IMG_PATH = '/mnt/rpi/boot.img';
const BOOT_SIG_PATH = '/mnt/rpi/boot.sig';

const EEPROM_IMAGE_BACKUP_PATH = '/mnt/data/pieeprom.upd.bak';
const EEPROM_SIG_BACKUP_PATH = '/mnt/data/pieeprom.sig.bak';
const BOOT_IMG_BACKUP_PATH = '/mnt/data/boot.img.bak';
const BOOT_SIG_BACKUP_PATH = '/mnt/data/boot.sig.bak';
const CONFIG_TXT_PATH = '/mnt/boot/config.txt';
const CONFIG_TXT_BACKUP_PATH = '/mnt/data/config.txt.bak';
const UPDATES_DISABLED_MESSAGE = 'EEPROM updates disabled in config.txt';
const ASSETS_DIR = path.join(os.tmpdir(), `leviathan-rpieeprom-assets-${process.pid}`);


const runCommandWithExitCode = async (context, link, command) => {
	const rawOutput = await context.get().worker.executeCommandInHostOS(
		`${command} 2>&1; echo $?`,
		link,
	);
	const lines = rawOutput.trim().split('\n');
	const exitCode = Number(lines.pop());
	return { output: lines.join('\n').trim(), exitCode };
};

const checkEepromCapabilitiesOrSkip = async (context, link, test) => {
	const updateScriptExitCode = (
		await runCommandWithExitCode(
			context,
			link,
			'test -x /usr/libexec/pieeprom-update.sh',
		)
	).exitCode;
	const flashromScriptExitCode = (
		await runCommandWithExitCode(
			context,
			link,
			'test -x /usr/libexec/pieeprom-flashrom.sh',
		)
	).exitCode;
	const pieepromUpdExitCode = (
		await runCommandWithExitCode(
			context,
			link,
			'test -f /mnt/boot/pieeprom.upd',
		)
	).exitCode;

	const allSupported = updateScriptExitCode === 0 && 	flashromScriptExitCode === 0 && pieepromUpdExitCode === 0;
	if (allSupported) {
		return true;
	}

	const allUnsupported = updateScriptExitCode !== 0 && flashromScriptExitCode !== 0 && pieepromUpdExitCode !== 0;
	if (allUnsupported) {
		test.comment('RPIEEPROM test not supported on this device; skipping');
		return false;
	}

	test.fail(
		`RPIEEPROM capability probe inconsistent; mixed exit codes detected. pieeprom-update.sh=${updateScriptExitCode}, pieeprom-flashrom.sh=${flashromScriptExitCode}, /mnt/boot/pieeprom.upd=${pieepromUpdExitCode}`,
	);
	return false;
};

const getBootloaderVersion = async (context, link) => {
	const output = await context
		.get()
		.worker.executeCommandInHostOS(
			`vcgencmd bootloader_version | grep timestamp | awk '{print $2}'`,
			link,
		);
	return output.trim();
};

const getFileMd5 = async (context, link, filePath) => {
	const output = await context
		.get()
		.worker.executeCommandInHostOS(`md5sum ${filePath} | awk '{print $1}'`, link);
	return output.trim();
};

const getFirmwareBuildTimestamp = async (context, link, firmwarePath) => {
	const output = await context
		.get()
		.worker.executeCommandInHostOS(
			`strings ${firmwarePath} | grep BUILD_TIMESTAMP | sed 's/.*=//'`,
			link,
		);
	return output.trim();
};

const validateTimestamp = (test, value, label) => {
	test.ok(/^\d+$/.test(value), `${label} should be a numeric unix timestamp`);
	test.ok(Number(value) > 0, `${label} should be greater than 0`);
};

const verifyDowngradeAssetSupportsSelfUpdate = async (
	context,
	link,
	test,
	pieepromUpdAsset,
) => {
	const selfUpdateSetting = await context
		.get()
		.worker.executeCommandInHostOS(
			`strings ${pieepromUpdAsset.stagingPath} | grep ENABLE_SELF_UPDATE || true`,
			link,
		);
	test.comment(
		`Downgrade pieeprom ENABLE_SELF_UPDATE entries: ${selfUpdateSetting.trim() || '(none found)'}`,
	);
	test.ok(
		!selfUpdateSetting.includes('ENABLE_SELF_UPDATE=0'),
		'Downgrade pieeprom should not disable self-update (no ENABLE_SELF_UPDATE=0)',
	);
};

const runFlashromUpdate = async (context, link, test) => {
	const { output, exitCode } = await runCommandWithExitCode(
		context,
		link,
		'/usr/libexec/pieeprom-flashrom.sh',
	);
	test.comment(`Flashrom output: ${output}`);
	test.ok(exitCode === 0, `Flashrom should exit with code 0 (got ${exitCode})`);
	test.ok(
		output.includes('SPI EEPROM fw update successful'),
		'Flashrom update should report success',
	);
};

const runEepromUpdate = async (context, link, image = 'pieeprom.upd') => {
	return runCommandWithExitCode(
		context,
		link,
		`/usr/libexec/pieeprom-update.sh ${image}`,
	);
};

const createCommonInitialFiles = () => ({
	pieepromUpd: {
		id: 'pieepromUpd',
		originalPath: EEPROM_IMAGE_PATH,
		backupPath: EEPROM_IMAGE_BACKUP_PATH,
		baselineMd5: null,
	},
	pieepromSig: {
		id: 'pieepromSig',
		originalPath: EEPROM_SIG_PATH,
		backupPath: EEPROM_SIG_BACKUP_PATH,
		baselineMd5: null,
	},
});

const createNonSbManifest = async (cloud) => {
	const assets = await prepareNonSecureBootDowngradeAssets(
		cloud,
		ASSETS_DIR,
	);

	return {
		downgradeAssets: {
			pieepromUpd: {
				id: 'pieepromUpd',
				sourcePath: assets.pieepromUpdPath,
				expectedMd5: NON_SB_EXPECTED_MD5.pieepromUpd,
				stagingPath: '/mnt/data/pieeprom.upd',
				targetPath: EEPROM_IMAGE_PATH,
			},
		},
		initialFiles: createCommonInitialFiles(),
	};
};

const createSbManifest = async (cloud) => {
	const assets = await prepareSecureBootDowngradeAssets(
		cloud,
		ASSETS_DIR,
	);

	return {
		downgradeAssets: {
			pieepromUpd: {
				id: 'pieepromUpd',
				sourcePath: assets.pieepromUpdPath,
				expectedMd5: SB_EXPECTED_MD5.pieepromUpd,
				stagingPath: '/mnt/data/pieeprom.upd',
				targetPath: EEPROM_IMAGE_PATH,
			},
			pieepromSig: {
				id: 'pieepromSig',
				sourcePath: assets.pieepromSigPath,
				expectedMd5: SB_EXPECTED_MD5.pieepromSig,
				stagingPath: '/mnt/data/pieeprom.sig',
				targetPath: EEPROM_SIG_PATH,
			},
			bootImg: {
				id: 'bootImg',
				sourcePath: assets.bootImgPath,
				expectedMd5: SB_EXPECTED_MD5.bootImg,
				stagingPath: '/mnt/data/boot.img',
				targetPath: BOOT_IMG_PATH,
			},
			bootSig: {
				id: 'bootSig',
				sourcePath: assets.bootSigPath,
				expectedMd5: SB_EXPECTED_MD5.bootSig,
				stagingPath: '/mnt/data/boot.sig',
				targetPath: BOOT_SIG_PATH,
			},
		},
		initialFiles: {
			...createCommonInitialFiles(),
			bootImg: {
				id: 'bootImg',
				originalPath: BOOT_IMG_PATH,
				backupPath: BOOT_IMG_BACKUP_PATH,
				baselineMd5: null,
			},
			bootSig: {
				id: 'bootSig',
				originalPath: BOOT_SIG_PATH,
				backupPath: BOOT_SIG_BACKUP_PATH,
				baselineMd5: null,
			},
		},
	};
};

// This detection logic is inspired by rpiSecureBoot in tests/secureboot/index.js.
const readRpiOtpReg = async (context, link, reg) => {
	const otpDump = await context
		.get()
		.worker.executeCommandInHostOS('vcgencmd otp_dump 2>/dev/null || true', link);
	for (const line of otpDump.split('\n')) {
		if (line.startsWith(`${reg}:`)) {
			return line.split(':')[1].trim();
		}
	}
	return '';
};

const rpiHasSecureBootOtpKeys = async (context, link) => {
	for (let reg = 47; reg <= 54; reg++) {
		const regValue = await readRpiOtpReg(context, link, reg);
		if (regValue && regValue !== '00000000') {
			return true;
		}
	}
	return false;
};

const readRpiPrivateKeyRegister = async (context, link) => {
	const mailboxOutput = await context
		.get()
		.worker.executeCommandInHostOS(
			'vcmailbox 0x00030081 40 40 0 8 0 0 0 0 0 0 0 0 2>/dev/null || true',
			link,
		);
	return mailboxOutput
		.replace(/0x/g, '')
		.trim()
		.split(/\s+/)
		.slice(7, 15)
		.join('');
};

const isRpiSecureBootEnabled = async (context, link) => {
	if (!(await rpiHasSecureBootOtpKeys(context, link))) {
		return false;
	}
	const key = await readRpiPrivateKeyRegister(context, link);
	return key.replace(/0/g, '').trim().length > 0;
};

const getManifest = async (isSecureBootEnabled, cloud, test) => {
	if (isSecureBootEnabled) {
		test.comment('Device reports secureboot enabled at runtime; selecting SB manifest');
		return createSbManifest(cloud);
	}
	test.comment('Device reports secureboot disabled at runtime; selecting non-SB manifest');
	return createNonSbManifest(cloud);
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

const verifyConfigTxtDisablesEepromUpdate = async (context, link, test) => {
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

};

const sendAndValidateDowngradeAsset = async (context, link, downgradeAssets, test) => {
	for (const asset of Object.values(downgradeAssets)) {
		await context.get().worker.sendFile(asset.sourcePath, asset.stagingPath, link);
		if (asset.expectedMd5) {
			const stagingMd5 = await getFileMd5(context, link, asset.stagingPath);
			test.is(
				stagingMd5,
				asset.expectedMd5,
				`${asset.id} md5 on DUT should match expected fixture checksum`,
			);
		}
	}

	const pieepromUpdAsset = downgradeAssets.pieepromUpd;
	if (pieepromUpdAsset == null) {
		throw new Error('Downgrade asset manifest is missing pieepromUpd entry');
	}
	const downgradeVersion = await getFirmwareBuildTimestamp(
		context,
		link,
		pieepromUpdAsset.stagingPath,
	);
	test.comment(`Downgrade pieeprom BUILD_TIMESTAMP: ${downgradeVersion}`);
	validateTimestamp(test, downgradeVersion, 'Downgrade pieeprom BUILD_TIMESTAMP');

	return downgradeVersion;
};

const deployDowngradeFirmware = async (context, link, downgradeAssets) => {
	const copyCommands = Object.values(downgradeAssets).map(
		(asset) => `cp ${asset.stagingPath} ${asset.targetPath}`,
	);
	await context.get().worker.executeCommandInHostOS(
		copyCommands.join(' && '),
		link,
	);
};

const captureInitialFileBaselineMd5 = async (context, link, initialFiles) => {
	for (const file of Object.values(initialFiles)) {
		file.baselineMd5 = await getFileMd5(context, link, file.originalPath);
	}
};

const testSetup = async (context, link, manifests, test) => {
	test.comment('Running EEPROM setup checks...');

	const shippedVersion = await getFirmwareBuildTimestamp(context, link, EEPROM_IMAGE_PATH);
	validateTimestamp(test, shippedVersion, 'Shipped firmware BUILD_TIMESTAMP');
	test.comment(`Shipped firmware BUILD_TIMESTAMP: ${shippedVersion}`);

	const currentVersion = await getBootloaderVersion(context, link);
	validateTimestamp(test, currentVersion, 'Current bootloader version');
	test.comment(`Current bootloader version: ${currentVersion}`);
	test.is(
		currentVersion,
		shippedVersion,
		'Running bootloader version should match shipped EEPROM image',
	);

	const downgradeVersion = await sendAndValidateDowngradeAsset(
		context,
		link,
		manifests.downgradeAssets,
		test,
	);
	await verifyDowngradeAssetSupportsSelfUpdate(
		context,
		link,
		test,
		manifests.downgradeAssets.pieepromUpd,
	);
	test.ok(
		Number(downgradeVersion) < Number(shippedVersion),
		'Downgrade firmware should be older than shipped EEPROM image',
	);

	await captureInitialFileBaselineMd5(context, link, manifests.initialFiles);

	return currentVersion;
};

const backUpInitialBootloaderFirmware = async (context, link, initialFiles, test) => {
	test.comment(
		'Moving original pieeprom.* and boot.* out of /mnt/boot and /mnt/rpi to prevent self-update until restore phase...',
	);
	for (const file of Object.values(initialFiles)) {
		await context
			.get()
			.worker.executeCommandInHostOS(
				`mv ${file.originalPath} ${file.backupPath}`,
				link,
			);
	}
};

const restoreInitialBootloaderFirmware = async (context, link, initialFiles) => {
	for (const file of Object.values(initialFiles)) {
		await context
			.get()
			.worker.executeCommandInHostOS(
				`cp ${file.backupPath} ${file.originalPath}`,
				link,
			);
	}
};

const restoreInitialBootloaderFirmwareInTeardown = async (context, link, initialFiles) => {
	for (const file of Object.values(initialFiles)) {
		await context.get().worker.executeCommandInHostOS(
			`if [ -f ${file.backupPath} ]; then mv -f ${file.backupPath} ${file.originalPath}; fi`,
			link,
		);
	}
};

const verifyTeardownEepromMd5 = async (context, link, test, initialFiles) => {
	for (const file of Object.values(initialFiles)) {
		if (file.baselineMd5 == null) {
			test.comment(`Post-teardown md5 check skipped for ${file.id} (no setup baseline)`);
			continue;
		}
		const restoredMd5 = await getFileMd5(context, link, file.originalPath);
		test.is(
			restoredMd5,
			file.baselineMd5,
			`${file.id} md5 should match setup baseline`,
		);
	}
};

const verifyTeardownEepromVersion = async (context, link, test, initialVersion) => {
	if (!initialVersion) {
		return;
	}
	const finalBootloaderVersion = await getBootloaderVersion(context, link);
	test.is(
		finalBootloaderVersion,
		initialVersion,
		'After teardown, running bootloader should match setup baseline version',
	);
};

const prepareForDowngrade = async (
	context,
	link,
	test,
	initialVersion,
	downgradeAssets,
) => {
	await deployDowngradeFirmware(context, link, downgradeAssets);
	const downgradeVersion = await getFirmwareBuildTimestamp(
		context,
		link,
		EEPROM_IMAGE_PATH,
	);
	test.comment(`Downgrade firmware BUILD_TIMESTAMP: ${downgradeVersion}`);
	validateTimestamp(test, downgradeVersion, 'Downgrade firmware BUILD_TIMESTAMP');
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
};

const downgradeBootloader = async (
	context,
	link,
	test,
	worker,
	initialVersion,
	manifests,
) => {
	await backUpInitialBootloaderFirmware(context, link, manifests.initialFiles, test);
	const downgradeVersion = await prepareForDowngrade(
		context,
		link,
		test,
		initialVersion,
		manifests.downgradeAssets,
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
	needRecoveryFlashrom,
	needTeardownRestoreConfigTxt,
	initialVersion,
	worker,
	manifests,
) => {
	if (needTeardownRestoreConfigTxt) {
		try {
			await restoreConfigTxt(context, link);
		} catch (error) {
			test.comment(`Teardown warning: failed to restore config.txt (${error.message})`);
		}
	}

	try {
		await restoreInitialBootloaderFirmwareInTeardown(
			context,
			link,
			manifests.initialFiles,
		);
	} catch (error) {
		test.comment(`Teardown warning: failed to restore assets (${error.message})`);
	}
	if (needRecoveryFlashrom) {
		try {
			await runFlashromUpdate(context, link, test);
			await worker.rebootDut(link);
		} catch (error) {
			test.comment(`Teardown warning: flashrom recovery failed (${error.message})`);
		}
	}
	await verifyTeardownEepromMd5(context, link, test, manifests.initialFiles);
	await verifyTeardownEepromVersion(context, link, test, initialVersion);
	await cleanupStagedDowngradeAssets(context, link, test, manifests.downgradeAssets);
};

const cleanupStagedDowngradeAssets = async (
	context,
	link,
	test,
	downgradeAssets,
) => {
	for (const asset of Object.values(downgradeAssets)) {
		try {
			await context
				.get()
				.worker.executeCommandInHostOS(`rm -f ${asset.stagingPath}`, link);
		} catch (error) {
			test.comment(
				`Teardown warning: failed to remove staged ${asset.id} from data partition (${error.message})`,
			);
		}
	}
};

const cleanupDownloadedAssetsDir = async (test) => {
	try {
		await fs.remove(ASSETS_DIR);
	} catch (error) {
		test.comment(
			`Teardown warning: failed to remove local downloaded assets dir (${error.message})`,
		);
	}
};

module.exports = {
	title: 'Raspberry Pi EEPROM update (flashrom + self-update) test',
	run: async function (test) {
		const context = this.context;
		const link = this.link;
		const canRunEepromTest = await checkEepromCapabilitiesOrSkip(context, link, test);
		if (!canRunEepromTest) {
			return;
		}

		test.comment(`testing if secureboot is enabled...`);
		const isSecureBootEnabled = await isRpiSecureBootEnabled(context, link);
		let initialVersion = null;
		let needRecoveryFlashrom = false;
		let needTeardownRestoreConfigTxt = false;

		const manifests = await getManifest(
			isSecureBootEnabled,
			this.context.get().cloud,
			test,
		);

		try {
			initialVersion = await testSetup(
				context,
				link,
				manifests,
				test,
			);

			test.comment('=== Test 1: Downgrade bootloader via flashrom ===');
			await downgradeBootloader(
				context,
				link,
				test,
				this.worker,
				initialVersion,
				manifests,
			);

			test.comment('=== Test 2: Restore shipped firmware and verify self-update ===');
			await restoreInitialBootloaderFirmware(
				context,
				link,
				manifests.initialFiles,
			);
			needRecoveryFlashrom = true;

			await this.worker.rebootDut(link);
			const postSelfUpdateVersion = await getBootloaderVersion(context, link);
			test.is(
				postSelfUpdateVersion,
				initialVersion,
				'After restore and reboot, self-update should return to initial bootloader version',
			);
			needRecoveryFlashrom = false;

			if (!isSecureBootEnabled) {
				test.comment('=== Test 3: Verify bootloader_update=0 disables updates for non sb devices ===');
				needTeardownRestoreConfigTxt = true;
				await verifyConfigTxtDisablesEepromUpdate(context, link, test);
				needTeardownRestoreConfigTxt = false;
			}
		} finally {
			await bestEffortTearDown(
				context,
				link,
				test,
				needRecoveryFlashrom,
				needTeardownRestoreConfigTxt,
				initialVersion,
				this.worker,
				manifests,
			);
			await cleanupDownloadedAssetsDir(test);
		}
	},
};
