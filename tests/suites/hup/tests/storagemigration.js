/*
 * Copyright 2021 balena
 *
 * @license Apache-2.0
 */

'use strict';

const shouldMigrate = async (that, test) => {
	// check if both aufs and overlayfs are supported, otherwise skip
	const storageDriver = await that.context
		.get()
		.worker.executeCommandInHostOS(
			`balena info 2>/dev/null | grep -o -e aufs -e overlay2`,
			that.context.get().link,
		);
	if (storageDriver === "overlay2") {
		test.comment(`SKIP: Already using overlayfs, skipping migration test.`)
		return false;
	}
	const hasDrivers = await that.context
		.get()
		.worker.executeCommandInHostOS(
			`grep -e overlay -e aufs /proc/filesystems >/dev/null; echo $?`,
			that.context.get().link,
		);
	// 0 means both drivers are supported available, 1 means at least one is missing
	if (hasDrivers === "1") {
		test.comment(`SKIP: Both aufs and overlayfs have to be supported to run a migration.`)
		return false;
	}
	return true;
}

const archiveMigrationLogs = async (that, test) => {
	await that.context.get().worker.archiveLogs(
		"storage-migration.log",
		that.context.get().link,
		// grab specifically migration logs
		// NOTE: this is a workaround to support devices that don't have a recent
		// enough journalctl binary to support `-b all`
		`journalctl --no-pager --no-hostname --list-boots | awk '{print $1}' | xargs -I{} sh -c 'set -x; journalctl --no-pager --no-hostname -b {} -u balena -t balenad | grep "to overlay2" || true;'`,
	);
	await that.context.get().worker.archiveLogs(
		"engine-containers-images.log",
		that.context.get().link,
		// list containers and images
		`set -x; balena container ls; balena image ls`,
	);
	await that.context.get().worker.archiveLogs(
		"engine-images-size.log",
		that.context.get().link,
		// this calculates the size of the images that were migrated
		// this is just an additional data point should migration fail
		`set -x; balena image ls --format '{{.Size}}' | awk 'BEGIN{t=0; k=1000;M=k*1000;G=M*1000;} /kB$/{sub("kB","");t+=($0*k);} /MB$/{sub("MB","");t+=($0*M);} /GB$/{sub("GB","");t+=($0*G);} END{print t}'`,
	);
}

const rebootAndWaitForRollbackHealth = async (that, test) => {
	// reduce number of failures needed to trigger rollback
	test.comment(`Reducing timeout for rollback-health...`);
	await that.context
		.get()
		.worker.executeCommandInHostOS(
			`sed -i -e "s/COUNT=.*/COUNT=3/g" -e "s/TIMEOUT=.*/TIMEOUT=20/g" $(find /mnt/sysroot/inactive/ | grep "bin/rollback-health")`,
			that.context.get().link,
		);

	await that.context.get().worker.rebootDut(that.context.get().link);

	// reboots should be finished when breadcrumbs are gone
	// check every 30s for 5 min since we are expecting multiple reboots
	test.comment(`Waiting for rollback-health.service to be inactive...`);
	await that.context.get().utils.waitUntil(
		async () => {
			return (
				(await that.context
					.get()
					.worker.executeCommandInHostOS(
						`test -f /mnt/state/rollback-health-breadcrumb ; echo $?`,
						that.context.get().link,
					)) === `1`
			);
		},
		false,
		10,
		30000,
	);
}

module.exports = {
	title: 'Storage migration test',
	deviceType: {
		type: 'object',
		required: [
			'slug'
		],
		properties: {
			slug: {
				type: 'string',
				enum: [
					'243390-rpi3',
					'beaglebone-black',
					'ccon-01',
					'intel-edison',
					'fst-controller',
					'intel-nuc',
					'odroid-c1',
					'raspberry-pi',
					'raspberry-pi2',
					'raspberrypi3',
					'raspberrypi3-64',
					'fincm3',
					'revpi-core3',
					'npe-x500-m3',
					'up-board',
					'val100',
				],
			},
		},
	},
	tests: [
		{
			title: 'Successful migration and cleanup on restart',
			run: async function(test) {
				await this.context.get().hup.initDUT(this, test, this.context.get().link);

				if (!(await shouldMigrate(this, test))) {
					return; // SKIP
				}

				const versionBeforeHup = await this.context
					.get()
					.worker.getOSVersion(this.context.get().link);

				test.comment(`OS version before HUP: ${versionBeforeHup}`);

				const containersBeforeHup = (await this.context
					.get()
					.worker.executeCommandInHostOS(
						`balena container ls --format '{{.ID}}'`,
						this.context.get().link,
					))
					.trim()
					.split('\n');

				test.comment(`Creating data to migrate`);
				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`balena pull balenalib/${this.suite.deviceType.slug}-debian:buster && balena run -d --name test balenalib/${this.suite.deviceType.slug}-debian:buster balena-idle`,
						this.context.get().link,
					);

				await this.context
					.get()
					.hup.doHUP(
						this,
						test,
						'image',
						this.context.get().hup.payload,
						this.context.get().link,
					);

				await rebootAndWaitForRollbackHealth(this, test);

				test.is(
					await this.context.get().worker.executeCommandInHostOS(
						`test -d /mnt/data/docker/overlay2 ; echo $?`,
						this.context.get().link),
					'0',
					'There should be an overlay2 directory under /var/lib/docker'
				);

				// 0 means directory exists, 1 means directory does not exist
				test.is(
					await this.context.get().worker.executeCommandInHostOS(
						`test -d /mnt/data/docker/aufs; echo $?`,
						this.context.get().link,
					),
					'0',
					'There should be a aufs directory under /var/lib/docker',
				);

				test.is(
					await this.context.get().worker.executeCommandInHostOS(
						`balena info 2>/dev/null | awk '/Storage.Driver/{print $3}'`,
						this.context.get().link),
					'overlay2',
					'balena-engine should be configured with the overlay2 storage driver'
				);

				const containersAfterHup = (await this.context
					.get()
					.worker.executeCommandInHostOS(
						`balena container ls --format '{{.ID}}' | xargs balena inspect --format '{{.GraphDriver.Name}}'`,
						this.context.get().link,
					))
					.trim()
					.split('\n');

				// compare the number of running containers
				test.is(
					containersAfterHup.length,
					containersBeforeHup.length,
					'All previous containers should run',
				)

				// false means at least 1 container was not configured with overlay2
				test.is(
					containersAfterHup.reduce((a, v) => a && (v === 'overlay2'), true),
					true,
					'All containers should be running on the overlay2 storage-driver',
				);

				test.comment(`Restarting engine`)

				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`systemctl restart balena`,
						this.context.get().link,
					);

				// 0 means directory does not exist, 1 means directory exists
				test.is(
					await this.context.get().worker.executeCommandInHostOS(
						`test ! -d /mnt/data/docker/aufs; echo $?`,
						this.context.get().link,
					),
					'0',
					'The aufs directory under /var/lib/docker should have been cleaned up',
				);

				await archiveMigrationLogs(this, test);
			},
		},
		{
			title: 'Migration should succeed when rollback triggers',
			run: async function(test) {
				await this.context.get().hup.initDUT(this, test, this.context.get().link);

				if (!(await shouldMigrate(this, test))) {
					return; // SKIP
				}

				const versionBeforeHup = await this.context
					.get()
					.worker.getOSVersion(this.context.get().link);

				test.comment(`OS version before HUP: ${versionBeforeHup}`);

				const containersBeforeHup = (await this.context
					.get()
					.worker.executeCommandInHostOS(
						`balena container ls --format '{{.ID}}'`,
						this.context.get().link,
					))
					.trim()
					.split('\n');

				await this.context
					.get()
					.hup.doHUP(
						this,
						test,
						'image',
						this.context.get().hup.payload,
						this.context.get().link,
					);

				// TODO: this copies a large chunk of the rollback-health/openvpn
				// test case. how useful is this? we just want to check that

				// break openvpn
				test.comment(`Breaking openvpn to trigger rollback-health...`);
				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`ln -sf /dev/null $(find /mnt/sysroot/inactive/ | grep "bin/openvpn$")`,
						this.context.get().link,
					);

				test.comment(
					`Pretend VPN was previously active for unmanaged OS suite...`,
				);
				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`sed 's/BALENAOS_ROLLBACK_VPNONLINE=0/BALENAOS_ROLLBACK_VPNONLINE=1/' -i /mnt/state/rollback-health-variables && sync -f /mnt/state`,
						this.context.get().link,
					);

				await rebootAndWaitForRollbackHealth(this, test);

				test.is(
					await this.context.get().worker.getOSVersion(this.context.get().link),
					versionBeforeHup,
					`The OS version should have reverted to ${versionBeforeHup}`,
				);

				// 0 means file exists, 1 means file does not exist
				test.is(
					await this.context
						.get()
						.worker.executeCommandInHostOS(
							`test -f /mnt/state/rollback-health-triggered ; echo $?`,
							this.context.get().link,
						),
					'0',
					'There should be a rollback-health-triggered file in the state partition',
				);

				// 0 means directory exists, 1 means directory does not exist
				test.is(
					await this.context.get().worker.executeCommandInHostOS(
						`test -d /mnt/data/docker/overlay2; echo $?`,
						this.context.get().link,
					),
					'0',
					'There should be a /mnt/data/docker/overlay2 directory, indicating that storage-migration was run.'
				);

				// check that the old storage driver is used by balena-engine
				test.is(
					await this.context.get().worker.executeCommandInHostOS(
						`balena info 2>/dev/null | awk '/Storage.Driver/{print $3}'`,
						this.context.get().link),
					'aufs',
					`The engine should be configured with the aufs storage driver`
				);

				const containersAfterHup = (await this.context
					.get()
					.worker.executeCommandInHostOS(
						`balena container ls --format '{{.ID}}' | xargs balena inspect --format '{{.GraphDriver.Name}}'`,
						this.context.get().link,
					))
					.trim()
					.split('\n');

				// check that we're still running the old containers
				test.is(
					containersAfterHup.length,
					containersBeforeHup.length,
					'All previous containers should run',
				)

				// false means at least 1 container was not configured with overlay2
				test.is(
					containersAfterHup.reduce((a, v) => a && (v === 'aufs'), true),
					true,
					`All containers should be running on the aufs storage-driver`,
				);

				await archiveMigrationLogs(this, test);
			},
		},
		{
			title: 'Migration failure should dump logs on state partition',
			run: async function(test) {
				await this.context.get().hup.initDUT(this, test, this.context.get().link);

				if (!(await shouldMigrate(this, test))) {
					return; // SKIP
				}

				const versionBeforeHup = await this.context
					.get()
					.worker.getOSVersion(this.context.get().link);

				test.comment(`OS version before HUP: ${versionBeforeHup}`);

				await this.context
					.get()
					.hup.doHUP(
						this,
						test,
						'image',
						this.context.get().hup.payload,
						this.context.get().link,
					);

				// make migration fail by messing up aufs storage root
				await this.context
					.get()
					.worker.executeCommandInHostOS(
						`systemctl stop balena-engine balena-supervisor; rm -rf /mnt/data/docker/aufs`,
						this.context.get().link,
					);

				await rebootAndWaitForRollbackHealth(this, test);

				// 0 means file exists, 1 means file does not exist
				test.is(
					await this.context.get().worker.executeCommandInHostOS(
						`test -f /mnt/state/balena-engine-storage-migration.log; echo $?`,
						this.context.get().link),
					'0',
					'There should be a storage-migration log file in the state partition'
				);

				await archiveMigrationLogs(this, test);
			},
		}
	]
};
