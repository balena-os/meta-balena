module.exports = {
	title: 'chrony tests',
	tests: [
		{
			title: 'Chronyd service',
			run: async function(test) {
				test.comment(`checking for chronyd service...`);
				let p = this.context.get().utils.waitUntil(async () => {
					return this.context.get().worker.executeCommandInHostOS(
						`systemctl is-active chronyd.service`,
						this.context.get().link,
					).then((result) => {
						return result === 'active';
					});
				}, false, 60, 1000);

				return test.resolves(p, 'Chronyd service should be running');
			},
		},
		{
			title: 'Sync test',
			run: async function(test) {
				let p = this.context.get().utils.waitUntil(async () => {
					test.comment('checking system clock synchronized...');
					return this.context.get().worker.executeCommandInHostOS(
							'timedatectl | grep System',
							this.context.get().link,
						).then((result) => {
							return result === 'System clock synchronized: yes';
						});
				}, false, 60, 1000);

				return test.resolves(p, 'System clock should be synchronized');
			},
		},
		{
			title: 'Source test',
			run: async function(test) {
				return this.context.get().worker.executeCommandInHostOS(
					`chronyc sources -n | fgrep '^*'`,
					this.context.get().link,
				).then((result) => {
					test.is(result !== '', true, 'Should see ^* next to chrony source');
				});
			},
		},
	],
};
