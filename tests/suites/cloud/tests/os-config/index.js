module.exports = {
	title: 'os-config tests',
	tests: [
		{
			title: 'os-config service on boot',
			run: async function(test) {
				return this.waitForServiceState(
							'os-config.service',
							'inactive',
							this.balena.uuid
				).then(async () => {
					test.is(
						 await this.cloud.executeCommandInHostOS(
							`journalctl -u os-config.service | grep -q "Service configuration retrieved" >/dev/null 2>&1 && echo "pass"`,
							this.balena.uuid),
						'pass',
						'Service configuration has been fetched on boot'
						)
				})
			},
		},
		{
			title: 'os-config service randomized timer',
			run: async function(test) {
				const nextTriggers = []
				let samples = 0
				do {
					nextTriggers.push( await this.worker.executeCommandInHostOS(
						`date -s "1 day" > /dev/null && sleep 0.5 && systemctl status os-config.timer | grep "Trigger:" | cut -d ';' -f2`,
						`${this.balena.uuid.slice(0, 7)}.local`)
					)
					samples = samples + 1
				} while (samples < 3);
				test.notOk (
					nextTriggers.every( (v, i, a) => v === a[0] ),
					'Service configuration has been fetched on a randomized timer'
				)
				/* Restore current time */
				await this.cloud.executeCommandInHostOS(
					`chronyc -a 'burst 4/4'`,
					this.balena.uuid)
			}
		},
	],
};
