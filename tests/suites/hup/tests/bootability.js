/*
 * Copyright 2026 Balena Ltd.
 *
 * @license Apache-2.0
 */

'use strict';

module.exports = {
	title: 'Bootability hook tests',
	tests: [
		{
			title: 'Bootability hook runs during HUP',
			run: async function (test) {
				if (!this.hostappPath) {
					await this.hup.initDUT(this, test, this.link);
				}

				await this.hup.doHUP(this, test, 'local', this.link);

				const sentinelExists = await this.worker.executeCommandInHostOS(
					`test -e /run/balena-hup-bootability-check && echo present || echo missing`,
					this.link,
				);
				test.is(
					sentinelExists,
					'present',
					'95-bootability sentinel file should exist on /run after HUP',
				);
			},
		},
	],
};
