
const blockNTP = async (that, test) => {
	return that.worker.executeCommandInHostOS(
		`journalctl --rotate --vacuum-time=1s`,
		that.link,
	).then(() => {
		// Stop DNS server to make NTP requests fail
		return that.worker.executeCommandInHostOS(
			`systemctl stop dnsmasq.service`,
			that.link,
		);
	}).then(() => {
		return that.worker.executeCommandInHostOS(
			`systemctl restart chronyd.service`,
			that.link
		);
	}).then(() => {
		return that.systemd.waitForServiceState('chronyd.service', 'active', that.link)
	});
}

const restoreNTP = async (that, test) => {
	return that.worker.executeCommandInHostOS(
		`systemctl restart dnsmasq`,
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
							const regex = /No online NTP sources - forcing poll/;
							return this.worker.executeCommandInHostOS(
								`journalctl -u chronyd.service`,
								this.link,
							).then(logs => {
								return Promise.resolve(regex.test(logs));
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
