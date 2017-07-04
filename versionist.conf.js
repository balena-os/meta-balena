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

const execSync = require('child_process').execSync;
const exec = require('child_process').exec;

const getAuthor = (commitHash) => {
  return execSync(`git show --quiet --format="%an" ${commitHash}`, {
    encoding: 'utf8'
  }).replace('\n', '');
};

const isIncrementalCommit = (changeType) => {
  return Boolean(changeType) && changeType.trim().toLowerCase() !== 'none';
};

// Update verison info in `meta-resin-common/conf/distro/include/resin-os.inc`
const metaUpdate = (cwd, version, callback) => {
  return exec(`sed -i 's/^DISTRO_VERSION = ".*"/DISTRO_VERSION = "${version}"/g' meta-resin-common/conf/distro/include/resin-os.inc`, {
    encoding: 'utf8',
  }, callback);
};

module.exports = {
  // This setup allows the editing and parsing of footer tags to get version and type information,
  // as well as ensuring tags of the type 'v<major>.<minor>.<patch>' are used.
  // It increments in a semver compatible fashion and does not do ano NPM package info update (N/A).
  editChangelog: true,
  parseFooterTags: true,
  getGitReferenceFromVersion: 'v-prefix',
  incrementVersion: 'semver',
  updateVersion: metaUpdate,

  // Always add the entry to the top of the Changelog, below the header.
  addEntryToChangelog: {
    preset: 'prepend',
    fromLine: 2
  },

  // Only include a commit when there is a footer tag of 'change-type'.
  // Ensures commits which do not up versions are not included.
  includeCommitWhen: (commit) => {
    return isIncrementalCommit(commit.footer['change-type']);
  },

  // Determine the type from 'change-type:' tag.
  // Should no explicit change type be made, then no changes are assumed.
  getIncrementLevelFromCommit: (commit) => {
    if (isIncrementalCommit(commit.footer['change-type'])) {
      return commit.footer['change-type'].trim().toLowerCase();
    }
  },

  // If a 'changelog-entry' tag is found, use this as the subject rather than the
  // first line of the commit.
  transformTemplateData: (data) => {
    data.commits.forEach((commit) => {
      commit.subject = commit.footer['changelog-entry'] || commit.subject;
      commit.author = getAuthor(commit.hash);
    });

    return data;
  },

  template: [
    '# v{{version}} - {{moment date "Y-MM-DD"}}',
    '',
    '{{#each commits}}',
    '{{#if this.author}}',
    '* {{capitalize this.subject}} [{{this.author}}]',
    '{{else}}',
    '* {{capitalize this.subject}}',
    '{{/if}}',
    '{{/each}}'
  ].join('\n')
};
