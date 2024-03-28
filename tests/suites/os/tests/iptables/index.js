'use strict';

module.exports = {
	title: 'iptables rules tests',
	tests: [
		{
			title: 'BALENA-FIREWALL test',
			run: async function(test) {
				let check = await this.worker.executeCommandInHostOS(
                    `iptables -L -vn -t filter | grep "Chain BALENA-FIREWALL" && echo $?`,
                    this.link
                )
                test.is(
                    check,
                    '0',
                    `BALENA-FIREWALL chain should be present in iptables rules`
                )
			},
		},
	],
};
