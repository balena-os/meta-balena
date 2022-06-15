
const blockNTP = async (that, test) => {
	test.comment('blocking NTP traffic on port 123...');
	// when supervisor starts up it flushes the INPUT table
	// so wait for supervisor to be active before stopping it
	return that.systemd.waitForServiceState('balena-supervisor.service', 'active', that.link)
	.then(async () => {
		return that.worker.executeCommandInHostOS(
			[
				`systemctl stop balena-supervisor`,
				`&&`,
				`journalctl --rotate`,
				`&&`,
				`journalctl --vacuum-time=1s`,
				`&&`,
				// make sure these rules take priority in the respective tables
				`/usr/sbin/iptables -I INPUT 1 -p udp --destination-port 123 -j DROP`,
				`&&`,
				`/usr/sbin/iptables -I OUTPUT 1 -p udp --destination-port 123 -j DROP`,
				`&&`,
				`systemctl restart chronyd.service`
			].join(' '),
			that.link,
		);
	}).then(async () => {
		return that.systemd.waitForServiceState('chronyd.service', 'active', that.link);
	});
}

const restoreNTP = async (that, test) => {
	test.comment('restoring NTP traffic on port 123...');
	return that.worker.executeCommandInHostOS(
		[
			`/usr/sbin/iptables -D INPUT -p udp --destination-port 123 -j DROP`,
			`&&`,
			`/usr/sbin/iptables -D OUTPUT -p udp --destination-port 123 -j DROP`,
			`&&`,
			`systemctl restart balena-supervisor`,
		].join(' '),
		that.link,
	);
}

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
				return blockNTP(this, test)
				.then(() => {
					return test.resolves(
						this.utils.waitUntil(async () => {
							return this.worker.executeCommandInHostOS(
									`journalctl -u chronyd.service | grep -q "No online NTP sources - forcing poll" >/dev/null 2>&1 ; echo $?`,
									this.link,
								)
								.then( (output) => {
									return Promise.resolve(output === '0')
								})
								.catch((err) => {
									Promise.reject(err)
								})
						}, false, 5 * 60, 1000),
						'Should force NTP poll when sources become offline'
					);
				}).then(() => {
					return restoreNTP(this, test);
				});
			},
		},
		{
			title: 'System time skew test',
			run: async function(test) {
				return blockNTP(this, test)
				.then(() => {
					return this.worker.executeCommandInHostOS(`date --set="-2min"`, this.link);
				}).then(() => {
					return test.resolves(
						this.utils.waitUntil(async () => {
							return this.worker.executeCommandInHostOS(
									`journalctl -u chronyd.service | grep -q "NTP time lost synchronization - restarting chronyd" >/dev/null 2>&1 ; echo $?`,
									this.link,
								)
								.then( (output) => {
									return Promise.resolve(output === '0')
								})
								.catch((err) => {
									Promise.reject(err)
								})
						}, false, 5 * 60, 1000),
						'Should restart chronyd when system time skew detected'
					);
				}).then(() => {
					return restoreNTP(this, test);
				});
			}
		},
	],
};
