/*
 * Copyright 2021 balena
 *
 * @license Apache-2.0
 */

'use strict';

const assignIn = require('lodash/assignIn');
const Bluebird = require('bluebird');
const SSH = require('node-ssh');

const fs = require('fs-extra');

// https://github.com/balena-os/balenahup/blob/85f4775459cdd36613a1be0ccae0a5d6d22f4091/upgrade-2.x.sh
const PROXY_SCRIPT = `${__dirname}/upgrade-2.x.sh`;

// TODO: pr this into leviathan

const getSSHClientDisposer = config => {
	const createSSHClient = conf => {
		return Bluebird.resolve(
			new SSH().connect(
				assignIn(
					{
						agent: process.env.SSH_AUTH_SOCK,
						keepaliveInterval: 20000,
					},
					conf,
				),
			),
		);
	};

	return createSSHClient(config).disposer(client => {
		client.dispose();
	});
}

const executeCommandOverSSH = async (command, config, opts) => {
	return Bluebird.using(getSSHClientDisposer(config), client => {
		return new Bluebird(async (resolve, reject) => {
			client.connection.on('error', err => {
				reject(err);
			});
			resolve(
				await client.exec(command, [],
					assignIn(
						{
							stream: 'both',
						},
						opts,
					),
				)
			);
		});
	});
}

module.exports = {
	title: 'Proxy HUP',
	run: async function(test) {
		await this.context.get().hup.initDUT(this, test, this.context.get().link);

		const versionBeforeHup = await this.context
			.get()
			.worker.getOSVersion(this.context.get().link);

		test.comment(`OS version before HUP: ${versionBeforeHup}`);

		// TODO: need to figure out the version of the verison of the PR image
		// also... can we use the apiUrl from config.js here?
		const versionAfterHup = versionBeforeHup;
		const args = [
			'--no-reboot',
			`--balenaos-registry=https://api.${this.context.get().suite.options.balena.apiUrl}`,
			`--hostos-version=${versionAfterHup}`,
		];
		const hup = await executeCommandOverSSH(
			`bash -s -x -- ${args.join(' ')}`,
			{
				host: (await this.context.get().worker.ip(this.context.get().link)),
				port: '22222',
				username: 'root',
			},
			{
				stdin: (await fs.readFile(PROXY_SCRIPT, 'utf-8')),
			},
		);
		test.comment(`${hup.stdout}`);

		// reduce number of failures needed to trigger rollback
		test.comment(`Reducing timeout for rollback-health...`);
		await this.context
			.get()
			.worker.executeCommandInHostOS(
				`sed -i -e "s/COUNT=.*/COUNT=3/g" -e "s/TIMEOUT=.*/TIMEOUT=20/g" $(find /mnt/sysroot/inactive/ | grep "bin/rollback-health")`,
				this.context.get().link,
			);

		await this.context.get().worker.rebootDut(this.context.get().link);

		// check every 5s for 2min
		// 0 means file exists, 1 means file does not exist
		test.comment(`Waiting for rollback-health-breadcrumb to be cleaned up...`);
		await this.context.get().utils.waitUntil(
			async () => {
				return (
					(await this.context
						.get()
						.worker.executeCommandInHostOS(
							`test -f /mnt/state/rollback-health-breadcrumb ; echo $?`,
							this.context.get().link,
						)) === `1`
				);
			},
			false,
			24,
			5000,
		);

	},
};
