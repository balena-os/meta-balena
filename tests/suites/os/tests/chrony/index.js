
const blockNTP = async (test, that, target) => {

	return test.test(`Blocking NTP by stopping dnsmasq.service`, t =>
		t.resolves(
			that.worker.executeCommandInHostOS(
				`journalctl --rotate --vacuum-time=1s`,
				target,
			),
			'Should rotate journal logs'
		).then(() => {
			return t.resolves(
				that.worker.executeCommandInHostOS(
					`systemctl stop dnsmasq.service`,
					target
				), `Should stop dnsmasq.service`
			);
		}).then(() => {
			// avoid hitting 'start request repeated too quickly'
			return t.resolves(
				that.worker.executeCommandInHostOS(
					'systemctl reset-failed chronyd.service',
					target
				), `Should reset start counter of chronyd.service`
			);
		}).then(() => {
			return t.resolves(
				that.worker.executeCommandInHostOS(
					`systemctl restart chronyd.service`,
					target
				), `Should restart chronyd.service`
			);
		}).then(() => {
			return t.resolves(
				that.systemd.waitForServiceState(
					'chronyd.service',
					'active',
					target
				),
				'Should wait for chronyd.service to be active'
			)
		}).then(() => {
			return t.resolves(
				that.systemd.waitForServiceState(
					'dnsmasq.service',
					'inactive',
					target
				),
				'Should wait for dnsmasq.service to be inactive'
			)
		})
	);
}

const restoreNTP = async (test, that, target) => {

	return test.test(`Unblocking NTP by restarting dnsmasq.service`, t =>
		t.resolves(
			// avoid hitting 'start request repeated too quickly'
			that.worker.executeCommandInHostOS(
				'systemctl reset-failed dnsmasq.service',
				target
			), `Should reset start counter of dnsmasq.service`
		).then(() => {
			return t.resolves(
				that.worker.executeCommandInHostOS(
					`systemctl restart dnsmasq.service`,
					target
				), `Should stop dnsmasq.service`
			);
		}).then(() => {
			return t.resolves(
				that.systemd.waitForServiceState(
					'dnsmasq.service',
					'active',
					target
				),
				'Should wait for dnsmasq.service to be active'
			)
		})
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
				await this.systemd.waitForServiceState('chronyd.service', 'active', this.link);
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
				return blockNTP(test, this, this.link)
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
						}, false, 5 * 60, 1000), // 5 min
						'Should force NTP poll when sources become offline'
					);
				}).then(() => {
					return restoreNTP(test, this, this.link);
				});
			},
		},
		{
			title: 'System time skew test',
			run: async function(test) {
				return blockNTP(test, this, this.link)
				.then(() => {
					return this.worker.executeCommandInHostOS(`date --set="-2min"`, this.link);
				}).then(() => {
					return test.resolves(
						this.utils.waitUntil(async () => {
							const regex = /NTP time lost synchronization - restarting chronyd/;
							return this.worker.executeCommandInHostOS(
									`journalctl -u chronyd.service`,
									this.link,
								).then(logs => {
									return Promise.resolve(regex.test(logs));
								})
						}, false, 5 * 60, 1000), // 5 min
						'Should restart chronyd when system time skew detected'
					);
				}).then(() => {
					return restoreNTP(test, this, this.link);
				});
			}
		},
	],
};
