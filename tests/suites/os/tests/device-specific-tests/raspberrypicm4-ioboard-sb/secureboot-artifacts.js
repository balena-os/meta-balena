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
const path = require('path');
const { Readable } = require('stream');
const { pipeline } = require('stream/promises');
const { inflateRawSync, crc32 } = require('zlib');
const { createRequire } = require('module');

const requireForFatFs = createRequire(__filename);
const fatfs = requireForFatFs('fatfs');

const IMAGE_JSON_ASSET_KEY = 'image.json';
const DEFLATE_ASSET_KEY = 'compressed/part-1.deflate';
const FAT_BOOT_IMG_FILENAME = 'boot.img';
const FAT_BOOT_SIG_FILENAME = 'boot.sig';
const FAT_PIEEPROM_SIG_FILENAME = 'pieeprom-latest-stable.sig';
const FAT_PIEEPROM_UPD_FILENAME = 'pieeprom-latest-stable.bin';

const EXPECTED_MD5 = {
	imageJson: 'c82946884356c95fe6a02787a6e67539',
	deflatePart: '23121f2f31a970b2b03cc5ba25fdc237',
	rawPart: '07bf969e60d6bcb84d19855f8f57b410',
	bootImg: 'fdc9ce5b7d68395035c7e25e0504a51c',
	bootSig: '003fd73d5ada4d308dd11934122e24a0',
	pieepromUpd: '9ed4ad66e1efd8db0c9b01f8d2d3ea09',
	pieepromSig: '68bcec5d2f09cc31c26d468053314761',
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
	const encoded = await fs.readFile(deflatePath);
	const decoded = inflateRawSync(
		Buffer.concat([encoded, Buffer.from([0x01, 0x00, 0x00, 0xff, 0xff])]),
	);
	if (decoded.length !== part.len) {
		throw new Error(`Decoded size mismatch: got ${decoded.length}, expected ${part.len}`);
	}
	const decodedCrc = crc32(decoded) >>> 0;
	if (decodedCrc !== (part.crc >>> 0)) {
		throw new Error(`CRC mismatch: got ${decodedCrc}, expected ${part.crc >>> 0}`);
	}
	await fs.writeFile(outputPath, decoded);
};

const createFatFsFromRawImage = async (rawImagePath) => {
	const handle = await fsPromises.open(rawImagePath, 'r');
	try {
		const stats = await handle.stat();
		const sectorSize = 512;
		const driver = {
			sectorSize,
			numSectors: Math.floor(stats.size / sectorSize),
			readSectors(i, dest, cb) {
				handle
					.read(dest, 0, dest.length, i * sectorSize)
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
	} catch (error) {
		await handle.close();
		throw error;
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

const extractFileFromRawPart = async (rawImagePath, fileInRaw, outputPath) => {
	const { fatVolume, handle } = await createFatFsFromRawImage(rawImagePath);
	try {
		const fileContent = await fatReadFile(fatVolume, fileInRaw);
		await fs.writeFile(outputPath, fileContent);
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

const prepareSecureBootDowngradeArtifacts = async (cloud, tmpdir, releaseId, test) => {
	const workDir = path.join(tmpdir, 'rpi4-secureboot-eeprom-assets');
	await fs.ensureDir(workDir);
	const imageJsonPath = path.join(workDir, 'image.json');
	const deflatePath = path.join(workDir, 'part-1.deflate');
	const rawPartPath = path.join(workDir, 'part-1.raw');
	const bootImgPath = path.join(workDir, 'boot.img');
	const bootSigPath = path.join(workDir, 'boot.sig');
	const pieepromUpdPath = path.join(workDir, 'pieeprom.upd');
	const pieepromSigPath = path.join(workDir, 'pieeprom.sig');

	// With balena-sdk > v22.1.0 we are going to be able to replace the pine query with:
	// const assets = await cloud.balena.models.release.asset.getAllByRelease(releaseId)
	const assets = await listReleaseAssets(cloud, releaseId);
	await downloadAssetByKey(assets, IMAGE_JSON_ASSET_KEY, imageJsonPath);
	await downloadAssetByKey(assets, DEFLATE_ASSET_KEY, deflatePath);
	await assertMd5(imageJsonPath, EXPECTED_MD5.imageJson, 'image.json');
	await assertMd5(deflatePath, EXPECTED_MD5.deflatePart, 'part-1.deflate');

	await extractRawPartFromDeflate(deflatePath, imageJsonPath, rawPartPath);
	await assertMd5(rawPartPath, EXPECTED_MD5.rawPart, 'part-1.raw');
	await extractFileFromRawPart(rawPartPath, FAT_BOOT_IMG_FILENAME, bootImgPath);
	await extractFileFromRawPart(rawPartPath, FAT_BOOT_SIG_FILENAME, bootSigPath);
	await extractFileFromRawPart(rawPartPath, FAT_PIEEPROM_UPD_FILENAME, pieepromUpdPath);
	await extractFileFromRawPart(rawPartPath, FAT_PIEEPROM_SIG_FILENAME, pieepromSigPath);

	await assertMd5(bootImgPath, EXPECTED_MD5.bootImg, 'boot.img');
	await assertMd5(bootSigPath, EXPECTED_MD5.bootSig, 'boot.sig');
	await assertMd5(pieepromUpdPath, EXPECTED_MD5.pieepromUpd, 'pieeprom-latest-stable.bin');
	await assertMd5(pieepromSigPath, EXPECTED_MD5.pieepromSig, 'pieeprom-latest-stable.sig');
	test.comment(`Prepared SB downgrade assets in ${workDir}`);
	return { bootImgPath, bootSigPath, pieepromUpdPath, pieepromSigPath };
};

module.exports = {
	prepareSecureBootDowngradeArtifacts,
};

