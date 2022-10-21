/*
 * Copyright 2021 balena
 *
 * @license Apache-2.0
 */

'use strict';

module.exports = {
	title: 'Smoke tests',
	tests: [
		{
			// HUP from the previous release to the release under test.
			title: 'HUP from previous release',
			run: async function (test) {
				// a check to see if there is a hostapp on the DUT already
				if(!this.hostappPath){
					await this.hup.initDUT(this, test, this.link);
				}
				await runSmokeTest(this, test);
			},
		},
		{
			// A second HUP to make sure the release under test didn't break
			// HUPs. (We are updating from the release under test to itself,
			// which is fine for our purposes.)
			title: 'HUP from this release',
			run: async function (test) {
				await runSmokeTest(this, test);
			},
		},
	],
};


async function runSmokeTest(that, test) {
	const activePartition = await that.worker.executeCommandInHostOS(
		`findmnt --noheadings --canonicalize --output SOURCE /mnt/sysroot/active`,
		that.link,
	);

	// Check for under-voltage before HUP, in the old OS
	await that.hup.checkUnderVoltage(that, test);


	test.comment(`Waiting to create volume on DUT`);
	await that.utils.waitUntil(async () => {
		return (
			(await that.worker.executeCommandInHostOS(
				`balena volume create hello-world`,
				that.link
				)) === 'hello-world'
		);
	}, true);
	
	test.ok(true, `Should create hello-world volume`);

	test.comment('Creating files on the volume');
	await that.worker.executeCommandInHostOS(
		`balena run -v hello-world:/the-volume --entrypoint "/bin/sh" alpine -c 'echo "Howdy!" > /the-volume/the-file.txt' &&
		balena run -v hello-world:/the-volume --entrypoint "/bin/sh" alpine -c 'md5sum /the-volume/the-file.txt > /the-volume/MD5.SUM'`,
		that.link,
	);

	await that.hup.doHUP(
		that,
		test,
		'local',
		that.link,
	);

	test.is(
		await that.worker.executeCommandInHostOS(
			`sed -i -e "s/COUNT=.*/COUNT=3/g" -e "s/TIMEOUT=.*/TIMEOUT=10/g" $(find /mnt/sysroot/inactive/ | grep "bin/rollback-health") ; echo $?`,
			that.link,
		),
		'0',	// does not confirm that sed replaced the values, only that the command did not fail
		'Should reduce rollback-health timeout to 3x10s'
	);

	await that.worker.rebootDut(that.link);

	// 0 means file exists, 1 means file does not exist
	await test.resolves(
		that.utils.waitUntil(async () => {
			return that.worker.executeCommandInHostOS(
				`test -f /mnt/state/rollback-health-breadcrumb ; echo $?`,
				that.link,
			).then(out => {
				return out === '1';
			})
		}, false, 5 * 60, 1000),	// 5 min
		'Should not have rollback-health-breadcrumb in the state partition'
	);

	// 0 means file exists, 1 means file does not exist
	test.is(
		await that.worker.executeCommandInHostOS(
			`test -f /mnt/state/rollback-altboot-breadcrumb ; echo $?`,
			that.link,
		),
		'1',
		'Should not have rollback-altboot-breadcrumb in the state partition',
	);

	// 0 means file exists, 1 means file does not exist
	test.is(
		await that.worker.executeCommandInHostOS(
			`test -f /mnt/state/rollback-altboot-triggered ; echo $?`,
			that.link,
		),
		'1',
		'Should not have rollback-altboot-triggered in the state partition',
	);

	// 0 means file exists, 1 means file does not exist
	test.is(
		await that.worker.executeCommandInHostOS(
			`test -f /mnt/state/rollback-health-triggered ; echo $?`,
			that.link,
		),
		'1',
		'Should not have rollback-health-triggered in the state partition',
	);

	// 0 means file exists, 1 means file does not exist
	test.is(
		await that.worker.executeCommandInHostOS(
			`test -f /mnt/state/rollback-health-failed ; echo $?`,
			that.link,
		),
		'1',
		'Should not have rollback-health-failed in the state partition',
	);

	test.not(
		await that.worker.executeCommandInHostOS(
			`findmnt --noheadings --canonicalize --output SOURCE /mnt/sysroot/active`,
			that.link,
		),
		activePartition,
		`Should not have rolled back to the original root partition`,
	);

	test.is(
		await that.worker.executeCommandInHostOS(
			`balena volume inspect hello-world 1>/dev/null 2>&1; echo $?`,
			that.link,
		),
		'0',
		'Volume should not be lost during HUP',
	);

	test.comment('Checking files on the volume');
	test.is(
		await that.worker.executeCommandInHostOS(
			`balena run -v hello-world:/the-volume alpine md5sum -c /the-volume/MD5.SUM &> /dev/null ; echo $?`,
			that.link,
		),
		'0',
		'Volume contents should have been preserved during HUP',
	);

	// Check for under-voltage after HUP, in the new OS
	await that.hup.checkUnderVoltage(that, test);
}
