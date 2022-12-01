/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

'use strict';

module.exports = {
	title: 'Reset tests',
	tests: [
		{
			title: 'state partition reset',
			run: async function (test) {
				const testFile = '/mnt/state/root-overlay/reset-check';
				const resetFile = '/mnt/state/remove_me_to_reset';
				await runResetTest(this, test, testFile, resetFile);
			},
		},
		{
			title: 'data partition reset',
			run: async function (test) {
				const testFile = '/mnt/data/resin-data/reset-check';
				const resetFile = '/mnt/data/remove_me_to_reset';
				await runResetTest(this, test, testFile, resetFile);
			},
		},
	],
};

async function runResetTest(that, test, testFile, resetFile) {
	test.is(
		await that.worker.executeCommandInHostOS(
			`touch ${testFile} ; echo $?`,
			that.link,
		),
		'0',
		`Should write test file ${testFile}`
	);

	test.is(
		await that.worker.executeCommandInHostOS(
			`rm ${resetFile} ; echo $?`,
			that.link,
		),
		'0',
		`Should clear reset file ${resetFile}`
	);

	// reboot
	await that.worker.rebootDut(that.link);

	await test.resolves(
		Promise.all([
			that.systemd.waitForServiceState('balena-supervisor.service','active',that.link), 
			that.systemd.waitForServiceState('balena.service','active',that.link)
		]),
		'Should wait for balena.service and balena-supervisor.service to be active'
	);

	test.is(
		await that.worker.executeCommandInHostOS(
				`/usr/lib/balena/balena-healthcheck >/dev/null 2>&1 ; echo $?`,
				that.link,
			),
		'0',
		'The engine healthcheck should pass',
	);

	await test.resolves(
		that.utils.waitUntil(async () => {
			return that.worker.executeCommandInHostOS(
				`curl -fs http://127.0.0.1:48484/ping || true`,
				that.link,
			).then((response) => {
				return Promise.resolve(response === 'OK');
			});
		}, false, 10 * 60 * 4, 250), // 10 min
		'The supervisor should respond to the ping endpoint'
	);

	test.is(
		await that.worker.executeCommandInHostOS(
				`test -f ${testFile} ; echo $?`,
				that.link,
			),
		'1',
		`Should clear test file ${testFile}`,
	);

	test.is(
		await that.worker.executeCommandInHostOS(
				`test -f ${resetFile} ; echo $?`,
				that.link,
			),
		'0',
		`Should restore reset file ${resetFile}`,
	);
}
