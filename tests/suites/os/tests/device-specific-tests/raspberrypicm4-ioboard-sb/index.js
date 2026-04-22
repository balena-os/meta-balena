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

const {
	prepareSecureBootDowngradeArtifacts,
} = require('./secureboot-artifacts');

const EEPROM_IMAGE_PATH = '/mnt/boot/pieeprom.upd';
const EEPROM_SIG_PATH = '/mnt/boot/pieeprom.sig';
const BOOT_IMG_PATH = '/mnt/rpi/boot.img';
const BOOT_SIG_PATH = '/mnt/rpi/boot.sig';

const EEPROM_IMAGE_BACKUP_PATH = '/mnt/data/pieeprom.upd.bak';
const EEPROM_SIG_BACKUP_PATH = '/mnt/data/pieeprom.sig.bak';
const BOOT_IMG_BACKUP_PATH = '/mnt/data/boot.img.bak';
const BOOT_SIG_BACKUP_PATH = '/mnt/data/boot.sig.bak';

const RELEASE_ID = 3921947;

let baselineMd5 = null;

const runCommandWithExitCode = async (context, link, command) => {
	const rawOutput = await context.get().worker.executeCommandInHostOS(
		`${command} 2>&1; echo $?`,
		link,
	);
	const lines = rawOutput.trim().split('\n');
	const exitCode = Number(lines.pop());
	return { output: lines.join('\n').trim(), exitCode };
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

const backupShippedArtifacts = async (context, link) => {
	await context.get().worker.executeCommandInHostOS(
		`cp ${EEPROM_IMAGE_PATH} ${EEPROM_IMAGE_BACKUP_PATH} && cp ${EEPROM_SIG_PATH} ${EEPROM_SIG_BACKUP_PATH} && cp ${BOOT_IMG_PATH} ${BOOT_IMG_BACKUP_PATH} && cp ${BOOT_SIG_PATH} ${BOOT_SIG_BACKUP_PATH}`,
		link,
	);
};

const restoreShippedArtifactsForSelfUpdate = async (context, link) => {
	await context.get().worker.executeCommandInHostOS(
		`cp ${EEPROM_IMAGE_BACKUP_PATH} ${EEPROM_IMAGE_PATH} && cp ${EEPROM_SIG_BACKUP_PATH} ${EEPROM_SIG_PATH} && cp ${BOOT_IMG_BACKUP_PATH} ${BOOT_IMG_PATH} && cp ${BOOT_SIG_BACKUP_PATH} ${BOOT_SIG_PATH}`,
		link,
	);
};

const restoreShippedArtifactsInTeardown = async (context, link) => {
	await context.get().worker.executeCommandInHostOS(
		`if [ -f ${EEPROM_IMAGE_BACKUP_PATH} ]; then mv -f ${EEPROM_IMAGE_BACKUP_PATH} ${EEPROM_IMAGE_PATH}; fi`,
		link,
	);
	await context.get().worker.executeCommandInHostOS(
		`if [ -f ${EEPROM_SIG_BACKUP_PATH} ]; then mv -f ${EEPROM_SIG_BACKUP_PATH} ${EEPROM_SIG_PATH}; fi`,
		link,
	);
	await context.get().worker.executeCommandInHostOS(
		`if [ -f ${BOOT_IMG_BACKUP_PATH} ]; then mv -f ${BOOT_IMG_BACKUP_PATH} ${BOOT_IMG_PATH}; fi`,
		link,
	);
	await context.get().worker.executeCommandInHostOS(
		`if [ -f ${BOOT_SIG_BACKUP_PATH} ]; then mv -f ${BOOT_SIG_BACKUP_PATH} ${BOOT_SIG_PATH}; fi`,
		link,
	);
};

const verifyTeardownMd5 = async (context, link, test) => {
	if (baselineMd5 == null) {
		return;
	}
	test.is(await getFileMd5(context, link, EEPROM_IMAGE_PATH), baselineMd5.eepromUpd, 'pieeprom.upd md5 restored');
	test.is(await getFileMd5(context, link, EEPROM_SIG_PATH), baselineMd5.eepromSig, 'pieeprom.sig md5 restored');
	test.is(await getFileMd5(context, link, BOOT_IMG_PATH), baselineMd5.bootImg, 'boot.img md5 restored');
	test.is(await getFileMd5(context, link, BOOT_SIG_PATH), baselineMd5.bootSig, 'boot.sig md5 restored');
};

module.exports = {
	// deviceType: {
	// 	type: 'object',
	// 	required: ['slug'],
	// 	properties: {
	// 		slug: {
	// 			type: 'string',
	// 			enum: ['raspberrypicm4-ioboard-sb'],
	// 		},
	// 	},
	// },
	title: 'RPi4 secureboot EEPROM update (flashrom + self-update) test',
	run: async function (test) {
		const context = this.context;
		const link = this.link;
		const initialVersion = await getBootloaderVersion(context, link);
		let needRecoveryFlashrom = false;

		// const artifacts = await prepareSecureBootDowngradeArtifacts(
		// 	this.context.get().cloud,
		// 	this.suite.options.tmpdir,
		// 	RELEASE_ID,
		// 	test,
		// );
		const artifacts = {
			pieepromUpdPath: path.join(__dirname, 'assets', 'pieeprom.upd'),
			pieepromSigPath: path.join(__dirname, 'assets', 'pieeprom.sig'),
			bootImgPath: path.join(__dirname, 'assets', 'boot.img'),
			bootSigPath: path.join(__dirname, 'assets', 'boot.sig'),
		};
		baselineMd5 = {
			eepromUpd: await getFileMd5(context, link, EEPROM_IMAGE_PATH),
			eepromSig: await getFileMd5(context, link, EEPROM_SIG_PATH),
			bootImg: await getFileMd5(context, link, BOOT_IMG_PATH),
			bootSig: await getFileMd5(context, link, BOOT_SIG_PATH),
		};

		try {
			await backupShippedArtifacts(context, link);

			await context.get().worker.sendFile(artifacts.pieepromUpdPath, '/mnt/data/pieeprom.upd', link);
			await context.get().worker.sendFile(artifacts.pieepromSigPath, '/mnt/data/pieeprom.sig', link);
			await context.get().worker.sendFile(artifacts.bootImgPath, '/mnt/data/boot.img', link);
			await context.get().worker.sendFile(artifacts.bootSigPath, '/mnt/data/boot.sig', link);

			await context.get().worker.executeCommandInHostOS(
				`cp /mnt/data/pieeprom.upd ${EEPROM_IMAGE_PATH} && cp /mnt/data/pieeprom.sig ${EEPROM_SIG_PATH} && cp /mnt/data/boot.img ${BOOT_IMG_PATH} && cp /mnt/data/boot.sig ${BOOT_SIG_PATH}`,
				link,
			);
			await runFlashromUpdate(context, link, test);
			await this.worker.rebootDut(link);
			const postFlashromVersion = await getBootloaderVersion(context, link);
			test.ok(
				postFlashromVersion !== initialVersion,
				`After flashrom downgrade and reboot, bootloader version should differ from initial (${initialVersion}), got ${postFlashromVersion}`,
			);
			await restoreShippedArtifactsForSelfUpdate(context, link);
			needRecoveryFlashrom = true;

			await this.worker.rebootDut(link);
			const postSelfUpdateVersion = await getBootloaderVersion(context, link);
			test.is(
				postSelfUpdateVersion,
				initialVersion,
				'After restore and reboot, secureboot self-update should return to initial bootloader version',
			);
			needRecoveryFlashrom = false;
		} finally {
			try {
				await restoreShippedArtifactsInTeardown(context, link);
			} catch (error) {
				test.comment(`Teardown warning: failed to restore artifacts (${error.message})`);
			}
			if (needRecoveryFlashrom) {
				try {
					await runFlashromUpdate(context, link, test);
					await this.worker.rebootDut(link);
				} catch (error) {
					test.comment(`Teardown warning: flashrom recovery failed (${error.message})`);
				}
			}
			await verifyTeardownMd5(context, link, test);
		}
	},
};

