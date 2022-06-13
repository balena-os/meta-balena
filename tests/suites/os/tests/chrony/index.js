module.exports = {
	title: 'chrony tests',
	tests: [
		{
			title: 'Chronyd service',
			run: async function(test) {
				test.comment(`checking for chronyd service...`);
				let result = '';
				await this.utils.waitUntil(async () => {
					result = await this.worker.executeCommandInHostOS(
							`systemctl is-active chronyd.service`,
							this.link,
						);
					return result === 'active';
				}, false, 2 * 60, 1000);
				result = await this.worker.executeCommandInHostOS(
						'systemctl status chronyd | grep running',
						this.link,
					);
				test.is(result !== '', true, 'Chronyd service should be running');
			},
		},
		{
			title: 'Sync test',
			run: async function(test) {
				let result = '';
				test.comment('checking system clock synchronized...');
				await this.utils.waitUntil(async () => {
					result = await this.worker.executeCommandInHostOS(
						'timedatectl | grep System',
						this.link,
					);
					return result === 'System clock synchronized: yes';
				}, false, 2 * 60, 1000);
				result = await this.worker.executeCommandInHostOS(
					'timedatectl | grep System',
					this.link,
				);
				test.is(
					result,
					'System clock synchronized: yes',
					'System clock should be synchronized',
				);
			},
		},
		{
			title: 'Source test',
			run: async function(test) {
				let result = '';
				result = await this.worker.executeCommandInHostOS(
						`chronyc sources -n | fgrep '^*'`,
						this.link,
					);
				test.is(result !== '', true, 'Should see ^* next to chrony source');
			},
		},
		{
			title: 'Offline sources test',
			run: async function(test) {
				await this.worker.executeCommandInHostOS(
						[
						`iptables-save > /var/run/iptables.back`,
						`&&`,
						`journalctl --rotate`,
						`&&`,
						`journalctl --vacuum-time=1s`
						].join(' '),
						this.link,
					);
				await this.worker.executeCommandInHostOS(
						[
						`/usr/sbin/iptables -F`,
						`&&`, `/usr/sbin/iptables -A INPUT -p udp --destination-port 123 -j DROP`,
						`&&`, `/usr/sbin/iptables -A OUTPUT -p udp --destination-port 123 -j DROP`,
						`&&`, `systemctl restart chronyd.service`
						].join(' '),
						this.link,
					);
				await this.systemd.waitForServiceState('chronyd.service', 'active', this.link)
				await this.utils.waitUntil(async () => {
					return this.worker.executeCommandInHostOS(
							`journalctl -u chronyd.service | grep -q "No online NTP sources - forcing poll" >/dev/null 2>&1 && echo "pass"`,
							this.link,
						)
						.then( (output) => {
							test.is(output === 'pass', true, 'Should force NTP poll when sources become offline');
							return Promise.resolve(output === 'pass')
						})
						.catch((err) => {
							Promise.reject(err)
						})
				}, false, 2 * 60, 1000)
			},
		},
		{
			title: 'System time skew test',
			run: async function(test) {
				await this.worker.executeCommandInHostOS(
						[
						`journalctl --rotate`,
						`&&`,
						`journalctl --vacuum-time=1s`,
						`&&`,
						`date --set="-2min"`,
						].join(' '),
						this.link,
					);
				await this.systemd.waitForServiceState('chronyd.service', 'active', this.link)
				await this.utils.waitUntil(async () => {
					return this.worker.executeCommandInHostOS(
							`journalctl -u chronyd.service | grep -q "NTP time lost synchronization - restarting chronyd" >/dev/null 2>&1 && echo "pass"`,
							this.link,
						)
						.then( (output) => {
							test.is(output === 'pass', true, 'Should restart chronyd when system time skew detected');
							return Promise.resolve(output === 'pass')
						})
						.catch((err) => {
							Promise.reject(err)
						})
				}, false, 2 * 60, 1000)
				await this.worker.executeCommandInHostOS(
						`iptables-restore < /var/run/iptables.back && rm -f /var/run/iptables.back`,
						this.link,
					);
			},
		},
	],
};
