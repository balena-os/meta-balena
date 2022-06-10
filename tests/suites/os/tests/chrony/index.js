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
	],
};
