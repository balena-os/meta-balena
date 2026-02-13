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
const fsPromises = require('node:fs/promises');
const nodeFs = require('node:fs');
const path = require('path');
const { Readable } = require('stream');
const { pipeline } = require('stream/promises');
const { promisify } = require('util');
const { createInflateRaw, crc32 } = require('zlib');
const { createRequire } = require('module');
const { withMountedDisk } = require('ext2fs');
const { FileDisk, withOpenFile } = require('file-disk');

const requireForFatFs = createRequire(__filename);
const fatfs = requireForFatFs('fatfs');

const IMAGE_JSON_ASSET_KEY = 'image.json';

// Secure boot assets globals
const SB_ROOTFS_DEFLATE_ASSET_KEY = 'compressed/part-2.deflate';
const SB_RELEASE_ID = 3921947;
const SB_FAT_BOOT_IMG_FILENAME = 'boot.img';
const SB_FAT_BOOT_SIG_FILENAME = 'boot.sig';
const SB_FAT_PIEEPROM_SIG_FILENAME = 'pieeprom-latest-stable.sig';
const SB_FAT_PIEEPROM_UPD_FILENAME = 'pieeprom-latest-stable.bin';
const SB_BALENA_OS_IMG_DIR = '/opt';
const SB_BALENA_OS_IMG_SUFFIX = '.balenaos-img';

const SB_EXPECTED_MD5 = {
	bootImg: '3dc850fc91ac65b355a0be14ef2162b3',
	bootSig: '39af6e8f0339e98cd921fbe6accdf13c',
	pieepromUpd: '9ed4ad66e1efd8db0c9b01f8d2d3ea09',
	pieepromSig: '68bcec5d2f09cc31c26d468053314761',
};

// Non-secureboot assets globals
const NON_SB_BOOT_DEFLATE_ASSET_KEY = 'compressed/part-1.deflate';
const NON_SB_RELEASE_ID = 3996259;
const NON_SB_FAT_PIEEPROM_UPD_FILENAME = 'pieeprom-latest-stable.bin';
const NON_SB_EXPECTED_MD5 = {
	pieepromUpd: '6462f1ae685d905c19360c08c5ce547e',
};

const downloadAssetByKey = async (assets, assetKey, outputPath) => {
	const target = assets.find((asset) => asset.asset_key === assetKey);
	if (target == null || target.asset == null || target.asset.href == null) {
		throw new Error(`Asset key not found or missing href: ${assetKey}`);
	}
	await fs.ensureDir(path.dirname(outputPath));
	const response = await fetch(target.asset.href);
	if (!response.ok || response.body == null) {
		throw new Error(`Download failed for ${assetKey} (HTTP ${response.status})`);
	}
	await pipeline(Readable.fromWeb(response.body), fs.createWriteStream(outputPath));
};

const md5File = async (filePath) => {
	const data = await fs.readFile(filePath);
	// Use shell md5sum-compatible output for consistency with fixture checks.
	const { createHash } = require('crypto');
	return createHash('md5').update(data).digest('hex');
};

const assertMd5 = async (filePath, expectedMd5, label) => {
	const actualMd5 = await md5File(filePath);
	if (actualMd5 !== expectedMd5) {
		throw new Error(`${label} md5 mismatch: got ${actualMd5}, expected ${expectedMd5}`);
	}
};

const findPartMetadata = (manifest, deflatePath) => {
	const partFilename = path.basename(deflatePath);
	for (const imageKey of Object.keys(manifest)) {
		const image = manifest[imageKey];
		if (!image || !Array.isArray(image.parts)) {
			continue;
		}
		const part = image.parts.find((candidate) => candidate.filename === partFilename);
		if (part != null) {
			return part;
		}
	}
	return null;
};

const extractRawPartFromDeflate = async (deflatePath, imageJsonPath, outputPath) => {
	const manifest = JSON.parse(await fs.readFile(imageJsonPath, 'utf8'));
	const part = findPartMetadata(manifest, deflatePath);
	if (part == null) {
		throw new Error(`Could not find metadata for ${path.basename(deflatePath)}`);
	}
	await fs.ensureDir(path.dirname(outputPath));
	const inflater = createInflateRaw();
	const output = nodeFs.createWriteStream(outputPath);
	let decodedLength = 0;
	let decodedCrc = 0;

	inflater.on('data', (chunk) => {
		decodedLength += chunk.length;
		decodedCrc = crc32(chunk, decodedCrc) >>> 0;
	});

	await new Promise((resolve, reject) => {
		const input = nodeFs.createReadStream(deflatePath);
		const finalizeBlock = Buffer.from([0x01, 0x00, 0x00, 0xff, 0xff]);

		const onError = (error) => reject(error);
		input.on('error', onError);
		inflater.on('error', onError);
		output.on('error', onError);
		output.on('finish', resolve);

		inflater.pipe(output);
		input.pipe(inflater, { end: false });
		input.on('end', () => inflater.end(finalizeBlock));
	});

	if (decodedLength !== part.len) {
		throw new Error(`Decoded size mismatch: got ${decodedLength}, expected ${part.len}`);
	}
	if (decodedCrc !== (part.crc >>> 0)) {
		throw new Error(`CRC mismatch: got ${decodedCrc}, expected ${part.crc >>> 0}`);
	}
};

const fatReadFile = async (fatVolume, filePath) => {
	return new Promise((resolve, reject) => {
		fatVolume.readFile(filePath, (error, data) => {
			if (error) {
				reject(error);
				return;
			}
			resolve(data);
		});
	});
};

const createFatFsFromHandle = async (
	handle,
	sectorSize,
	numSectors,
	baseOffset = 0,
) => {
	const driver = {
		sectorSize,
		numSectors,
		readSectors(i, dest, cb) {
			handle
				.read(dest, 0, dest.length, baseOffset + i * sectorSize)
				.then(() => cb(null))
				.catch((error) => cb(error));
		},
	};
	const fatVolume = await new Promise((resolve, reject) => {
		const volume = fatfs.createFileSystem(driver, { ro: true });
		volume.on('ready', () => resolve(volume));
		volume.on('error', reject);
	});
	return { fatVolume, handle };
};

const createFatFsFromRawImage = async (rawImagePath) => {
	const handle = await fsPromises.open(rawImagePath, 'r');
	try {
		const stats = await handle.stat();
		const sectorSize = 512;

		return createFatFsFromHandle(
			handle,
			sectorSize,
			Math.floor(stats.size / sectorSize),
		);
	} catch (error) {
		await handle.close();
		throw error;
	}
};

const extractFileFromRawPart = async (rawImagePath, fileInRaw, outputPath) => {
	const { fatVolume, handle } = await createFatFsFromRawImage(rawImagePath);
	try {
		const fileContent = await fatReadFile(fatVolume, fileInRaw);
		await fs.ensureDir(path.dirname(outputPath));
		await fs.writeFile(outputPath, fileContent);
	} finally {
		await handle.close();
	}
};

const findBalenaOsImgFilename = (entries) => {
	const matches = entries.filter((value) => value.endsWith(SB_BALENA_OS_IMG_SUFFIX));
	if (matches.length === 0) {
		throw new Error(
			`No ${SB_BALENA_OS_IMG_SUFFIX} file found under ${SB_BALENA_OS_IMG_DIR}`,
		);
	}
	return matches[0];
};

const copyMountedFileToHostPath = async (mountedFs, sourcePath, outputPath) => {
	const open = promisify(mountedFs.open.bind(mountedFs));
	const read = promisify(mountedFs.read.bind(mountedFs));
	const close = promisify(mountedFs.close.bind(mountedFs));
	const stat = promisify(mountedFs.stat.bind(mountedFs));

	const sourceStat = await stat(sourcePath);
	const chunkSize = 4 * 1024 * 1024;
	let sourceFd;
	let outputHandle;
	try {
		sourceFd = await open(sourcePath, 'r');
		outputHandle = await fsPromises.open(outputPath, 'w');
		let position = 0;
		while (position < sourceStat.size) {
			const nextChunkSize = Math.min(chunkSize, sourceStat.size - position);
			const buffer = Buffer.allocUnsafe(nextChunkSize);
			const bytesRead = await read(
				sourceFd,
				buffer,
				0,
				nextChunkSize,
				position,
			);
			if (bytesRead <= 0) {
				break;
			}
			await outputHandle.write(
				buffer.subarray(0, bytesRead),
				0,
				bytesRead,
				position,
			);
			position += bytesRead;
		}
	} finally {
		if (outputHandle != null) {
			await outputHandle.close();
		}
		if (sourceFd != null) {
			await close(sourceFd);
		}
	}
};

const extractBalenaOsImageFromRootfsRaw = async (rawImagePath, outputDir) => {
	return withOpenFile(rawImagePath, 'r', async (handle) => {
		const disk = new FileDisk(handle, true);
		return withMountedDisk(disk, 0, async (filesystem) => {
			const mountedFs =
				filesystem.promises == null ? filesystem : filesystem.promises;
			const entries = await mountedFs.readdir(SB_BALENA_OS_IMG_DIR);
			const balenaOsImgFilename = findBalenaOsImgFilename(entries);
			const sourcePath = path.posix.join(SB_BALENA_OS_IMG_DIR, balenaOsImgFilename);
			const outputPath = path.join(outputDir, balenaOsImgFilename);
			await fs.ensureDir(path.dirname(outputPath));
			await copyMountedFileToHostPath(filesystem, sourcePath, outputPath);
			return outputPath;
		});
	});
};

const createFatFsFromImagePartition = async (imagePath, partitionNumber) => {
	const handle = await fsPromises.open(imagePath, 'r');
	try {
		// MBR (DOS partition table) layout offsets and sizes.
		const MBR_SECTOR_SIZE = 512;
		const MBR_PARTITION_TABLE_OFFSET = 446;
		const MBR_PARTITION_ENTRY_SIZE = 16;
		const MBR_PARTITION_START_LBA_OFFSET = 8;
		const MBR_PARTITION_NUM_SECTORS_OFFSET = 12;

		const mbr = Buffer.alloc(MBR_SECTOR_SIZE);
		await handle.read(mbr, 0, mbr.length, 0);
		const entryOffset =
			MBR_PARTITION_TABLE_OFFSET + (partitionNumber - 1) * MBR_PARTITION_ENTRY_SIZE;
		const startSector = mbr.readUInt32LE(entryOffset + MBR_PARTITION_START_LBA_OFFSET);
		const numSectors = mbr.readUInt32LE(entryOffset + MBR_PARTITION_NUM_SECTORS_OFFSET);
		if (startSector === 0 || numSectors === 0) {
			throw new Error(`Invalid partition ${partitionNumber} in ${imagePath}`);
		}
		const sectorSize = MBR_SECTOR_SIZE;
		const baseOffset = startSector * sectorSize;

		return createFatFsFromHandle(handle, sectorSize, numSectors, baseOffset);
	} catch (error) {
		await handle.close();
		throw error;
	}
};

const extractBootAssetsFromBalenaOsImage = async (
	imagePath,
	bootImgPath,
	bootSigPath,
	pieepromUpdPath,
	pieepromSigPath,
) => {
	const { fatVolume, handle } = await createFatFsFromImagePartition(imagePath, 1);

	try {
		const bootImg = await fatReadFile(fatVolume, SB_FAT_BOOT_IMG_FILENAME);
		const bootSig = await fatReadFile(fatVolume, SB_FAT_BOOT_SIG_FILENAME);
		const pieepromUpd = await fatReadFile(fatVolume, SB_FAT_PIEEPROM_UPD_FILENAME);
		const pieepromSig = await fatReadFile(fatVolume, SB_FAT_PIEEPROM_SIG_FILENAME);
		await fs.writeFile(bootImgPath, bootImg);
		await fs.writeFile(bootSigPath, bootSig);
		// Normalize filenames expected by the test workflow.
		await fs.writeFile(pieepromUpdPath, pieepromUpd);
		await fs.writeFile(pieepromSigPath, pieepromSig);
	} finally {
		await handle.close();
	}
};

const listReleaseAssets = async (cloud, releaseRef) => {
	const numericReleaseId = Number(releaseRef);
	if (!Number.isInteger(numericReleaseId)) {
		throw new Error('Pine asset query requires a numeric release id');
	}
	const release = await cloud.pine.get({
		resource: 'release',
		id: numericReleaseId,
		options: {
			$select: ['id'],
			$expand: {
				release_asset: {
					$orderby: 'id asc',
					$select: ['id', 'asset', 'asset_key'],
					$filter: {
						asset: { $ne: null },
					},
				},
			},
		},
	});
	return release.release_asset || [];
};

const prepareSecureBootDowngradeAssets = async (
	cloud,
	outputDir,
) => {
	if (!outputDir) {
		throw new Error('prepareSecureBootDowngradeAssets requires outputDir');
	}
	await fs.ensureDir(outputDir);
	const imageJsonPath = path.join(outputDir, 'image.json');
	const rootfsDeflatePath = path.join(outputDir, 'part-2.deflate');
	const rootfsRawPartPath = path.join(outputDir, 'part-2.raw');
	const bootImgPath = path.join(outputDir, 'boot.img');
	const bootSigPath = path.join(outputDir, 'boot.sig');
	const pieepromUpdPath = path.join(outputDir, 'pieeprom.upd');
	const pieepromSigPath = path.join(outputDir, 'pieeprom.sig');

	// With balena-sdk > v22.1.0 we are going to be able to replace the pine query with:
	// const assets = await cloud.balena.models.release.asset.getAllByRelease(SB_RELEASE_ID)
	const assets = await listReleaseAssets(cloud, SB_RELEASE_ID);
	await downloadAssetByKey(assets, IMAGE_JSON_ASSET_KEY, imageJsonPath);
	await downloadAssetByKey(assets, SB_ROOTFS_DEFLATE_ASSET_KEY, rootfsDeflatePath);

	await extractRawPartFromDeflate(rootfsDeflatePath, imageJsonPath, rootfsRawPartPath);

	const extractedBalenaOsImagePath = await extractBalenaOsImageFromRootfsRaw(
		rootfsRawPartPath,
		outputDir,
	);

	await extractBootAssetsFromBalenaOsImage(
		extractedBalenaOsImagePath,
		bootImgPath,
		bootSigPath,
		pieepromUpdPath,
		pieepromSigPath,
	);

	await assertMd5(bootImgPath, SB_EXPECTED_MD5.bootImg, 'boot.img');
	await assertMd5(bootSigPath, SB_EXPECTED_MD5.bootSig, 'boot.sig');
	await assertMd5(pieepromUpdPath, SB_EXPECTED_MD5.pieepromUpd, 'pieeprom-latest-stable.bin');
	await assertMd5(pieepromSigPath, SB_EXPECTED_MD5.pieepromSig, 'pieeprom-latest-stable.sig');
	return { bootImgPath, bootSigPath, pieepromUpdPath, pieepromSigPath };
};

const prepareNonSecureBootDowngradeAssets = async (
	cloud,
	outputDir,
) => {
	if (!outputDir) {
		throw new Error('prepareNonSecureBootDowngradeAssets requires outputDir');
	}
	await fs.ensureDir(outputDir);
	const imageJsonPath = path.join(outputDir, 'image.json');
	const bootDeflatePath = path.join(outputDir, 'part-1.deflate');
	const bootRawPartPath = path.join(outputDir, 'part-1.raw');
	const pieepromUpdPath = path.join(outputDir, 'pieeprom-latest-stable.bin');

	const assets = await listReleaseAssets(cloud, NON_SB_RELEASE_ID);
	await downloadAssetByKey(assets, IMAGE_JSON_ASSET_KEY, imageJsonPath);
	await downloadAssetByKey(assets, NON_SB_BOOT_DEFLATE_ASSET_KEY, bootDeflatePath);
	await extractRawPartFromDeflate(bootDeflatePath, imageJsonPath, bootRawPartPath);
	await extractFileFromRawPart(
		bootRawPartPath,
		NON_SB_FAT_PIEEPROM_UPD_FILENAME,
		pieepromUpdPath,
	);
	await assertMd5(
		pieepromUpdPath,
		NON_SB_EXPECTED_MD5.pieepromUpd,
		'pieeprom-latest-stable.bin',
	);
	return { pieepromUpdPath };
};

module.exports = {
	prepareSecureBootDowngradeAssets,
	prepareNonSecureBootDowngradeAssets,
	SB_EXPECTED_MD5,
	NON_SB_EXPECTED_MD5,
};

