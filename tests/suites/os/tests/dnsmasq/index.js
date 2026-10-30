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

const DBUS_NAME = 'uk.org.thekelleys.dnsmasq';
const DBUS_PATH = '/uk/org/thekelleys/dnsmasq';

const BALENA_CONF = '/etc/dnsmasq.d/balena.conf';
const BALENA_DIRECTIVES = ['enable-dbus', 'domain-needed', 'bogus-priv'];

// TEST-NET-3 address, scoped to a domain that never resolves, so the DUT
// keeps working while the probe server is installed.
const PROBE_SERVER = '203.0.113.53';
const PROBE_DOMAIN = 'dbus-probe.invalid';

const dnsmasqCall = async (that, method, args) => {
	return that.worker.executeCommandInHostOS(
		['busctl', '--system', 'call', DBUS_NAME, DBUS_PATH, DBUS_NAME, method]
			.concat(args)
			.join(' '),
		that.link,
		{ max_tries: 3, interval: 1000 },
	);
};

module.exports = {
	title: 'dnsmasq tests',
	tests: [
		{
			title: 'balena directives test',
			run: async function(test) {
				const found = await this.worker.executeCommandInHostOS(
					`grep -c -x -e ${BALENA_DIRECTIVES.join(' -e ')} ${BALENA_CONF} || true`,
					this.link,
				);
				test.is(
					found,
					`${BALENA_DIRECTIVES.length}`,
					`${BALENA_CONF} should carry the balena directives`,
				);
			},
		},
		{
			title: 'D-Bus name test',
			run: async function(test) {
				await this.systemd.waitForServiceState('dnsmasq.service', 'active', this.link);

				await test.resolves(
					this.utils.waitUntil(async () => {
						return this.worker.executeCommandInHostOS(
							'busctl --system --acquired --no-pager list',
							this.link,
						).then((names) => {
							return Promise.resolve(names.includes(DBUS_NAME));
						});
					}, false, 20, 500),
					`dnsmasq should own ${DBUS_NAME} on the system bus`,
				);
			},
		},
		{
			title: 'SetServersEx test',
			run: async function(test) {
				// A restart drops the probe server, which D-Bus state holds
				test.teardown(async () => {
					await this.worker.executeCommandInHostOS(
						'systemctl restart dnsmasq.service || true',
						this.link,
					);
				});

				await this.systemd.waitForServiceState('dnsmasq.service', 'active', this.link);

				await test.resolves(
					dnsmasqCall(this, 'SetServersEx', [
						'aas', '1', '2', PROBE_SERVER, PROBE_DOMAIN,
					]),
					'SetServersEx should accept a domain scoped server',
				);

				// Match the address, not the generic log line, which an earlier
				// D-Bus caller may have left in this invocation
				await test.resolves(
					this.systemd.waitForJournal('dnsmasq.service', PROBE_SERVER, this.link),
					`dnsmasq should use ${PROBE_SERVER} after SetServersEx`,
				);
			},
		},
	],
};
