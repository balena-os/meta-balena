'use strict';

const iptablesHeadings = [
	'pkts',
	'bytes',
	'target',
	'prot', 
	'opt', 
	'in',    
	'out',
	'source',
	'destination'         
]

function parseIptablesRule(rule){
	const splitRule = rule.split(/\s+/);
	let parsedRule = {};
	for(let i in iptablesHeadings){
		parsedRule[iptablesHeadings[i]] = splitRule[i];
	}
	return parsedRule
}

module.exports = {
	title: 'iptables rules tests',
	tests: [
		{
			// sanity check to see that balena0 rule is in place
			title: 'Firewall sanity check',
			run: async function(test) {

				const expectedRules = [
					{
						target: "MASQUERADE",
						in: '*',
						out: "!balena0"
					},
				]

				for(let rule of expectedRules){
					let check = await this.worker.executeCommandInHostOS(
						`iptables -t nat -L -vn | grep '${rule.out}'`,
						this.link
					)
					const parsedRule = parseIptablesRule(check);
					for(let key of Object.keys(rule)){
						test.is(
							parsedRule[key],
							rule[key],
							`Should see ${key} as ${rule[key]} value for interface ${rule.out}`
						)
					}
				}
			},
		},
		{
			// Test to check that the iptables firewall rules added by the supervisor are visible to the hostOS
			// More detailed checks on specific rules are carried out in the supervisor tests 
			// https://github.com/balena-os/balena-supervisor/blob/14e91779f443354c7283cb24a21f973871ca21e7/test/integration/lib/firewall.spec.ts 
			title: 'BALENA-FIREWALL test',
			run: async function(test) {

				// before starting these tests, ensure the supervisor is running, so its had a chance to add its rules
				await this.utils.waitUntil(async () => {
					let healthy = await this.worker.executeCommandInHostOS(
					`curl --max-time 10 "localhost:48484/v1/healthy"`,
					this.link
					)
					return (healthy === 'OK')
				}, true, 120, 250)

				let check = await this.worker.executeCommandInHostOS(
                    `iptables -t filter -L BALENA-FIREWALL -vn |wc -l`,
                    this.link
                )
				// checking for more than 10 rules - depending on the scenario I've seen between 13 - 17 rules.
				// If 10 are present, its safe to say the supervisor rules are visible in the hostOS
                test.is(
                    (Number(check) > 10),
                    true,
                    `BALENA-FIREWALL chain should be present in iptables rules`
                )
			},
		},
	],
};
