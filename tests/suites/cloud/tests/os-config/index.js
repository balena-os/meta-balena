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
				const getTrigger = async () => {
					let trigger;
					await this.utils.waitUntil(async () => {
					  // on slower hardware this command can return an empty string so don't proceed
					  // until we have a value for trigger
					  trigger = await this.cloud.executeCommandInHostOS(
						`systemctl status os-config.timer | grep "Trigger:" | awk '{print $4}'`,
						this.balena.uuid
					  );
					  return (trigger !== "" && !trigger.includes('error'));
					}, false, 20, 500)
					return trigger;
				}
				// Start from the trigger before any restart, so that every restart
				// has to change it
				const nextTriggers = [ await getTrigger() ]
				let samples = 0
				do {
					// Restarting the timer picks a new random delay. Changing the
					// clock does that too, but it also drops the VPN connection
					// this command goes through, so its result gets lost
					await this.cloud.executeCommandInHostOS(
						`systemctl restart os-config.timer`,
						this.balena.uuid
					);
					nextTriggers.push( await getTrigger() );
					samples = samples + 1;
				} while (samples < 3);
				console.log(nextTriggers)
				test.ok (
					// check that all results are unique
					(new Set(nextTriggers)).size === nextTriggers.length,
					'Service configuration will be fetched on a randomized timer'
				  )
			}
		},
	],
};
