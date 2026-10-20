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

const BUNDLE = '/etc/ssl/certs/ca-certificates.crt';
const BALENA_CA_FILE = '/usr/share/ca-certificates/balena/balenaRootCA.crt';
const BUNDLE_STAMP = '/etc/ssl/certs/.balena-bundle-inputs';
const STATE_CERTS_DIR = '/mnt/state/root-overlay/etc/ssl/certs';

const readPem = (name) => fs.readFileSync(`${__dirname}/assets/${name}`, 'utf8');

// The base64 body of a PEM is the DER encoding, so it matches the bundle
// regardless of line wrapping
const pemBody = (pem) => pem.replace(/-----[^-]+-----/g, '').replace(/\s/g, '');

// Roots that chain to the compromised eMudhra intermediates
const DISTRUSTED_ROOTS = {
	'emSign ECC Root CA - G3': readPem('emsign-ecc-root-ca-g3.pem'),
	'Comodo AAA Services root': readPem('comodo-aaa-services-root.pem'),
};
const ISRG_ROOT_X1 = readPem('isrg-root-x1.pem');
// The private key of this CA was discarded when it was generated
const TEST_CA = readPem('throwaway-test-ca.pem');

async function bundleHas(that, pem) {
	const out = await that.worker.executeCommandInHostOS(
		`tr -d '\\n' < ${BUNDLE} | grep -qF '${pemBody(pem)}'; echo $?`,
		that.link,
	);
	return out === '0';
}

async function bundleInode(that) {
	return that.worker.executeCommandInHostOS(`stat -c %i ${BUNDLE}`, that.link);
}

async function assertBundleRoots(that, test) {
	for (const [name, pem] of Object.entries(DISTRUSTED_ROOTS)) {
		test.false(await bundleHas(that, pem), `Bundle should not contain ${name}`);
	}
	// Positive control: prove that the bundle check finds a root that is present
	test.true(await bundleHas(that, ISRG_ROOT_X1), 'Bundle should contain ISRG Root X1');
}

async function restartExtractBalenaCa(that) {
	return that.worker.executeCommandInHostOS(
		'systemctl restart extract-balena-ca.service',
		that.link,
	);
}

module.exports = {
	title: 'CA certificates tests',
	tests: [
		{
			title: 'Rootfs bundle omits distrusted roots',
			run: async function (test) {
				await assertBundleRoots(this, test);
			},
		},
		{
			title: 'Custom CA bundle omits distrusted roots and refreshes when stale',
			run: async function (test) {
				const existing = await this.worker.executeCommandInHostOS(
					`test -e ${BALENA_CA_FILE}; echo $?`,
					this.link,
				);
				if (existing === '0') {
					test.comment(`${BALENA_CA_FILE} already exists - skipping`);
					return;
				}

				await this.systemd.writeConfigJsonProp(
					test,
					'balenaRootCA',
					Buffer.from(TEST_CA).toString('base64'),
					this.link,
				);
				await restartExtractBalenaCa(this);

				test.is(
					await this.worker.executeCommandInHostOS(
						'systemctl is-active bind-etc-ssl-certs.service',
						this.link,
					),
					'active',
					'/etc/ssl/certs should be bind mounted from the state partition',
				);
				test.true(await bundleHas(this, TEST_CA), 'Bundle should contain the custom CA');
				await assertBundleRoots(this, test);

				// A hostOS update leaves the bundle in the state partition as it was.
				// Simulate a bundle from an older hostOS that still trusts a distrusted root.
				const [staleName, stalePem] = Object.entries(DISTRUSTED_ROOTS)[0];
				await this.worker.executeCommandInHostOS(
					[
						`echo ${Buffer.from(stalePem).toString('base64')} | base64 -d >> ${BUNDLE}`,
						`&&`, `echo stale > ${BUNDLE_STAMP}`,
					].join(' '),
					this.link,
				);
				test.true(
					await bundleHas(this, stalePem),
					`Bundle should contain ${staleName} after the simulated stale update`,
				);

				await restartExtractBalenaCa(this);
				test.false(
					await bundleHas(this, stalePem),
					`Bundle should not contain ${staleName} after the rebuild`,
				);
				test.true(await bundleHas(this, TEST_CA), 'Bundle should still contain the custom CA');

				// update-ca-certificates replaces the bundle file, so an unchanged
				// inode means no rebuild
				const inode = await bundleInode(this);
				await restartExtractBalenaCa(this);
				test.is(
					await bundleInode(this),
					inode,
					'Bundle should not be rebuilt when its inputs are unchanged',
				);

				// Remove the CA file before the config.json property, because the
				// property change restarts balena-supervisor, which reads the file
				await this.worker.executeCommandInHostOS(`rm -f ${BALENA_CA_FILE}`, this.link);
				await this.systemd.writeConfigJsonProp(test, 'balenaRootCA', null, this.link);
				await this.worker.executeCommandInHostOS(
					[
						'systemctl stop bind-etc-ssl-certs.service',
						`&&`, `rm -rf ${STATE_CERTS_DIR}`,
					].join(' '),
					this.link,
				);
				test.false(
					await bundleHas(this, TEST_CA),
					'Rootfs bundle should not contain the custom CA after cleanup',
				);
			},
		},
	],
};
