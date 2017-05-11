/*
 * Copyright 2017 resin.io
 *
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

//const path = require('path');
//const semver = require('semver');

module.exports = {
	defaultInitialVersion: '2.0.3',
	changelogFile: 'CHANGELOG.md',
	editChangelog: true,
	editVersion: true,
	lowerCaseFooterTags: true,
	parseFooterTags: true,
	includeMergeCommits: false,

	getGitReferenceFromVersion: 'v-prefix',

	addEntryToChangelog: {
		preset: 'prepend',
		fromLine: 3
	},

	includeCommitWhen: (commit) => {
		return commit.footer['Change-Type'];
	},

	getIncrementLevelFromCommit: (commit) => {
		return commit.footer['Change-Type'];
	},

	updateVersion: (cwd, version, callback) => {
		return null;
		const distroIncPath = path.join(cwd, 'meta-resin-common/conf/distro/include/resin-os.inc');
		const cleanedVersion = semver.clean(version);
		if (!cleanedVersion) {
			return callback(new Error(`Invalid version: ${version}`));
		}
		var r = new FileReader();
		return null;
	},

	transformTemplateData: (data) => {
		data.major = data.commits.filter(function (el) {
			return el.footer['Change-Type'] == 'major';
		});
		data.minor = data.commits.filter(function (el) {
			return el.footer['Change-Type'] == 'minor';
		});
		data.patch = data.commits.filter(function (el) {
			return el.footer['Change-Type'] == 'patch';
		});
		return data;
	},

	template: ['## v{{version}} - {{moment date "Y-MM-DD"}}',
		'{{#if major.length}}',
			'',
			'### Major changes',
			'',
			'{{#each major}}',
				'- {{subject}}',
			'{{/each}}',
		'{{/if}}',
		'{{#if minor.length}}',
			'',
			'### Minor changes',
			'',
			'{{#each minor}}',
				'- {{subject}}',
			'{{/each}}',
		'{{/if}}',
		'{{#if patch.length}}',
			'',
			'### Patch changes',
			'',
			'{{#each patch}}',
				'- {{subject}}',
			'{{/each}}',
		'{{/if}}',
	].join('\n')
};
