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

module.exports = {
	title: 'Config.json configuration tests',
	tests: [
		{
			title: 'hostname configuration test',
			run: async function(test) {
				const hostname = Math.random()
					.toString(36)
					.substring(2, 10);

				// Add hostname
				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`tmp=$(mktemp)&&cat /mnt/boot/config.json | jq '.hostname="${hostname}"' > $tmp&&mv "$tmp" /mnt/boot/config.json`,
						this.context.get().link,
					);

				// Wait for new hostname to be active
				test.comment(`Waiting for avahi service to be active...`);
				await this.context.get().utils.waitUntil(async () => {
					return (
						(await this.context
							.get()
							.worker.executeCommandInHostOS(
								`systemctl is-active avahi-daemon.service`,
								`${hostname}.local`,
							)) === 'active'
					);
				}, false);

				test.equal(
					await this.context
						.get()
						.worker.executeCommandInHostOS(
							'cat /etc/hostname',
							`${hostname}.local`,
						),
					hostname,
					'Device should have new hostname',
				);

				// Remove hostname
				await this.context
					.get()
					.worker.executeCommandInHostOS(
						'tmp=$(mktemp)&&cat /mnt/boot/config.json | jq "del(.hostname)" > $tmp&&mv "$tmp" /mnt/boot/config.json',
						`${hostname}.local`,
					);


				// Wait for old hostname to be active again
				test.comment(`Waiting for avahi service to be active...`);
				await this.context.get().utils.waitUntil(async () => {
					return (
						(await this.context
							.get()
							.worker.executeCommandInHostOS(
								`systemctl is-active avahi-daemon.service`,
								this.context.get().link,
							)) === 'active'
					);
				}, false);
			},
		},
		{
			title: 'ntpServer test',
			run: async function(test) {
				const ntpServer = (regex = '') => {
					return `time${regex}.google.com`;
				};

				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`tmp=$(mktemp)&&cat /mnt/boot/config.json | jq '.ntpServers="${ntpServer()}"' > $tmp&&mv "$tmp" /mnt/boot/config.json`,
						this.context.get().link,
					);

				// Wait for new NTP server to be active
				test.comment(`Waiting for balena-ntp-config service to be active...`);
				await this.context.get().utils.waitUntil(async () => {
					return (
						(await this.context
							.get()
							.worker.executeCommandInHostOS(
								`systemctl is-active balena-ntp-config.service`,
								this.context.get().link,
							)) === 'active'
					);
				}, false, 5, 30000);

				await test.resolves(
					this.context
						.get()
						.worker.executeCommandInHostOS(
							`chronyc sources | grep ${ntpServer('.*')}`,
							this.context.get().link,
						),
					'Device should show one record with our ntp server',
				);

				await this.context
					.get()
					.worker.executeCommandInHostOS(
						'tmp=$(mktemp)&&cat /mnt/boot/config.json | jq "del(.ntpServers)" > $tmp&&mv "$tmp" /mnt/boot/config.json',
						this.context.get().link,
					);
			},
		},
		{
			title: 'dnsServers test',
			run: async function(test) {
				const defaultDns = '8.8.8.8';
				const exampleDns = '1.1.1.1';

				test.comment(
					`Waiting for dnsmasq to be active and using ${defaultDns}...`,
				);
				await this.context.get().utils.waitUntil(async () => {
					return (
						(await this.context
							.get()
							.worker.executeCommandInHostOS(
								`journalctl _SYSTEMD_INVOCATION_ID="$(systemctl show -p InvocationID --value dnsmasq.service)" | grep -q ${defaultDns} ; echo $?`,
								this.context.get().link,
							)) === '0'
					);
				}, false);

				test.comment(`Setting dnsServers="${exampleDns}" in config.json...`);
				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`tmp=$(mktemp) && jq '.dnsServers="${exampleDns}"' /mnt/boot/config.json > $tmp && mv "$tmp" /mnt/boot/config.json`,
						this.context.get().link,
					);

				test.comment(
					`Waiting for dnsmasq to be active and using ${exampleDns}...`,
				);
				await this.context.get().utils.waitUntil(async () => {
					return (
						(await this.context
							.get()
							.worker.executeCommandInHostOS(
								`journalctl _SYSTEMD_INVOCATION_ID="$(systemctl show -p InvocationID --value dnsmasq.service)" | grep -q ${exampleDns} ; echo $?`,
								this.context.get().link,
							)) === '0'
					);
				}, false);

				test.comment(`Setting dnsServers="null" in config.json...`);
				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`tmp=$(mktemp) && jq '.dnsServers="null"' /mnt/boot/config.json > $tmp && mv "$tmp" /mnt/boot/config.json`,
						this.context.get().link,
					);

				test.comment(`Waiting for dnsmasq service to be active...`);
				await this.context.get().utils.waitUntil(async () => {
					return (
						(await this.context
							.get()
							.worker.executeCommandInHostOS(
								`systemctl is-active dnsmasq.service`,
								this.context.get().link,
							)) === 'active'
					);
				}, false);

				test.is(
					await this.context
						.get()
						.worker.executeCommandInHostOS(
							`journalctl _SYSTEMD_INVOCATION_ID="$(systemctl show -p InvocationID --value dnsmasq.service)" | grep -q ${defaultDns} ; echo $?`,
							this.context.get().link,
						),
					'1',
					`Active dnsmasq service should not be using ${defaultDns}.`,
				);

				test.is(
					await this.context
						.get()
						.worker.executeCommandInHostOS(
							`journalctl _SYSTEMD_INVOCATION_ID="$(systemctl show -p InvocationID --value dnsmasq.service)" | grep -q ${exampleDns} ; echo $?`,
							this.context.get().link,
						),
					'1',
					`Active dnsmasq service should not be using ${exampleDns}.`,
				);

        test.is(
					await this.context
						.get()
						.worker.executeCommandInHostOS(
							`journalctl _SYSTEMD_INVOCATION_ID="$(systemctl show -p InvocationID --value dnsmasq.service)" | grep -q "bad address" ; echo $?`,
							this.context.get().link,
						),
					'1',
					`Active dnsmasq service should not log "bad address".`,
				);

				test.comment(`Removing dnsServers field from config.json...`);
				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`tmp=$(mktemp) && jq "del(.dnsServers)" /mnt/boot/config.json > $tmp && mv "$tmp" /mnt/boot/config.json`,
						this.context.get().link,
					);

				test.comment(
					`Waiting for dnsmasq to be active and using ${defaultDns}...`,
				);
				await this.context.get().utils.waitUntil(async () => {
					return (
						(await this.context
							.get()
							.worker.executeCommandInHostOS(
								`journalctl _SYSTEMD_INVOCATION_ID="$(systemctl show -p InvocationID --value dnsmasq.service)" | grep -q ${defaultDns} ; echo $?`,
								this.context.get().link,
							)) === '0'
					);
				}, false);
			},
		},
		{
			title: 'os.network.connectivity test',
			os: {
				type: 'object',
				required: ['version'],
				properties: {
					version: {
						type: 'string',
						semver: {
							gt: '2.34.0',
						},
					},
				},
			},
			run: async function(test) {
				const connectivity = {
					uri: 'http://www.archlinux.org/check_network_status.txt',
				};

				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`tmp=$(mktemp)&&cat /mnt/boot/config.json | jq '.os.network.connectivity=${JSON.stringify(
							connectivity,
						)}' > $tmp&&mv "$tmp" /mnt/boot/config.json`,
						this.context.get().link,
					);

				// Rebooting the DUT
				await this.context.get().worker.rebootDut(this.context.get().link);

				const config = await this.context
					.get()
					.worker.executeCommandInHostOS(
						'NetworkManager --print-config | awk "/\\[connectivity\\]/{flag=1;next}/\\[/{flag=0}flag"',
						this.context.get().link,
					);

				test.is(
					/uri=(.*)\n/.exec(config)[1],
					connectivity.uri,
					`NetworkManager should be configured with uri: ${connectivity.uri}`,
				);

				await this.context
					.get()
					.worker.executeCommandInHostOS(
						'tmp=$(mktemp)&&cat /mnt/boot/config.json | jq "del(.os.network.connectivity)" > $tmp&&mv "$tmp" /mnt/boot/config.json',
						this.context.get().link,
					);
			},
		},
		{
			title: 'os.network.wifi.randomMacAddressScan test',
			run: async function(test) {
				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`tmp=$(mktemp)&&cat /mnt/boot/config.json | jq '.os.network.wifi.randomMacAddressScan=true' > $tmp&&mv "$tmp" /mnt/boot/config.json`,
						this.context.get().link,
					);

				// Rebooting the DUT
				await this.context.get().worker.rebootDut(this.context.get().link);

				const config = await this.context
					.get()
					.worker.executeCommandInHostOS(
						'NetworkManager --print-config | awk "/\\[device\\]/{flag=1;next}/\\[/{flag=0}flag"',
						this.context.get().link,
					);

				test.match(
					config,
					/wifi.scan-rand-mac-address=yes/,
					'NetworkManager should be configured to randomize wifi MAC',
				);

				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`tmp=$(mktemp)&&cat /mnt/boot/config.json | jq 'del(.os.network.wifi)' > $tmp&&mv "$tmp" /mnt/boot/config.json`,
						this.context.get().link,
					);
			},
		},
		{
			title: 'udevRules test',
			run: async function(test) {
				const rule = {
					99: 'ENV{ID_FS_LABEL_ENC}=="resin-boot", SYMLINK+="disk/test"',
				};

				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`tmp=$(mktemp)&&cat /mnt/boot/config.json | jq '.os.udevRules=${JSON.stringify(
							rule,
						)}' > $tmp&&mv "$tmp" /mnt/boot/config.json`,
						this.context.get().link,
					);

				// Rebooting the DUT
				await this.context.get().worker.rebootDut(this.context.get().link);

				test.is(
					await this.context
						.get()
						.worker.executeCommandInHostOS(
							'readlink -e /dev/disk/test',
							this.context.get().link,
						),
					await this.context
						.get()
						.worker.executeCommandInHostOS(
							'readlink -e /dev/disk/by-label/resin-boot',
							this.context.get().link,
						),
					'Dev link should point to the correct device',
				);

				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`tmp=$(mktemp)&&cat /mnt/boot/config.json | jq 'del(.os.udevRules)' > $tmp&&mv "$tmp" /mnt/boot/config.json`,
						this.context.get().link,
					);
			},
		},
		{
			title: 'sshKeys test',
			run: async function(test) {
				await test.resolves(
					this.context
						.get()
						.worker.executeCommandInHostOS(
							'echo true',
							this.context.get().link,
						),
					'Should be able to establish ssh connection to the device',
				);
			},
		},
		{
			title: 'persistentLogging configuration test',
			run: async function(test) {
				const bootCount = parseInt(
					await this.context
						.get()
						.worker.executeCommandInHostOS(
							'journalctl --list-boots | wc -l',
							this.context.get().link,
						),
				);

				test.comment('Attempting first reboot');
				await this.context.get().worker.rebootDut(this.context.get().link);

				test.comment('Attempting second reboot');
				await this.context.get().worker.rebootDut(this.context.get().link);

				const testcount = parseInt(
					await this.context
						.get()
						.worker.executeCommandInHostOS(
							'journalctl --list-boots | wc -l',
							this.context.get().link,
						),
				);
				test.is(
					testcount === bootCount + 2,
					true,
					`Device should show previous boot records, showed ${testcount} boots`,
				);
			},
		},
	],
};
