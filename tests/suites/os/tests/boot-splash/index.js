/*
 * Copyright 2019 balena
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

const fs = require('fs');
const { decode } = require('jpeg-js');
const { createGunzip } = require('zlib');
const tar = require('tar-stream');

const BOOT_SPLASH = `${__dirname}/assets/boot-splash.jpg`;

module.exports = {
	title: 'Balena boot splash tests',
	deviceType: {
		type: 'object',
		required: ['data'],
		properties: {
			data: {
				type: 'object',
				required: ['hdmi'],
				properties: {
					hdmi: {
						type: 'boolean',
						const: true,
					},
				},
			},
		},
	},
	tests: [
		{
			title: 'Reboot test',
			run: async function(test) {
				const { hammingDistance, blockhash } = this.require('/common/graphics');

				await this.context.get().worker.capture('start');

				// Start reboot check
				await this.context
					.get()
					.worker.executeCommandInHostOS(
						'touch /tmp/reboot-check',
						this.context.get().link,
					);
				await this.context
					.get()
					.worker.executeCommandInHostOS(
						'systemd-run --on-active=2 /sbin/reboot',
						this.context.get().link,
					);
				await this.context.get().utils.waitUntil(async () => {
					return (
						(await this.context
							.get()
							.worker.executeCommandInHostOS(
								'[[ ! -f /tmp/reboot-check ]] && echo "pass"',
								this.context.get().link,
							)) === 'pass'
					);
				});

				// Pull in the reference image
				const referenceHash = await new Promise((resolve, reject) => {
					const stream = fs.createReadStream(BOOT_SPLASH);
					const buffer = [];

					stream.on('error', reject);
					stream.on('data', data => {
						buffer.push(data);
					});
					stream.on('end', () => {
						resolve(blockhash(decode(Buffer.concat(buffer))));
					});
				});

				// Collect all decoded images here
				const imagesHash = [];
				await new Promise((resolve, reject) => {
					const extract = tar.extract();
					extract.on('entry', async (_header, stream, next) => {
						const buffer = [];

						let archiveStream;

						if (_header.type !== 'directory') {
							archiveStream = await this.archiver.getStream(_header.name);
						}

						stream.on('data', data => {
							buffer.push(data);

							if (archiveStream != null) {
								archiveStream.write(data);
							}
						});
						stream.on('end', () => {
							if (buffer.length > 0) {
								imagesHash.push(blockhash(decode(Buffer.concat(buffer))));
							}

							next();
						});
					});

					const res = this.context.get().worker.capture('stop');
					res.on('error', error => {
						reject(error);
					});
					res.on('response', response => {
						if (response.statusCode === 500) {
							const buffer = [];
							res.on('data', data => {
								buffer.push(data);
							});
							res.on('end', () => {
								reject(new Error(Buffer.concat(buffer).toString()));
							});
						} else {
							res
								.pipe(createGunzip())
								.pipe(extract)
								.on('error', reject)
								.on('finish', resolve);
						}
					});
				});

				const count = imagesHash.filter(hash => {
					return hammingDistance(referenceHash, hash) < 20;
				}).length;

				test.true(
					count > 0,
					'More than one frame of our boot-splash should have been captured',
				);
			},
		},
	],
};
