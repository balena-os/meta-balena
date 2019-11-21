# Contributing

To contribute send github pull requests targeting [this](https://github.com/balena-os/meta-balena) repository.

Please refer to: [Yocto Contribution Guidelines](https://wiki.yoctoproject.org/wiki/Contribution_Guidelines#General_Information) and try to use the commit log format as stated there. Example:
```
test.bb: I added a test

[Issue #01]

I'm going to explain here what my commit does in a way that history
would be useful.

Signed-off-by: Joe Developer <joe.developer@example.com>
```

We take advantage of a change log file to keep track of what was changed in a specific version. We used to handle that file manually by adding entries to it at every pull request. In order to avoid racing issues when pushing multiple PRs, we started to use versionist which will generate the change log at every release. This tool uses two footers from commit log: `Change-type` and `Changelog-entry`. Each PR needs to have at least one commit which will specify both of these two commit log footers. In this way, when a new release is handled, the next version will be computed based on `Change-type` and the entries in the change log file will be generated based on `Changelog-entry`.

In the common case where each PR addresses one specific task (issue, bug, feature etc.) the PR will contain a commit which will include `Change-type` and `Changelog-entry` in its commit log. Usually, but not necessary, this commit is the last one in the branch.

`Change-type` is mandatory and, because meta-balena follows semver, can take one of the following values: patch, minor or major. `Changelog-entry` defaults to the subject line.

## Updating balena-supervisor

When the supervisor is updated in meta-balena, versionist will attempt to pull in the relevant slice of changelog from the supervisor and add it to the changelog of meta-balena. For this to happen, the commit that updates the supervisor must follow a specific format: the first line of the BODY must contain `Update balena-supervisor from x.y.z to x'.y'.z'` The title and footers can be filled in as normal.

N.B. just `Update balena-supervisor from x.y.z to x'.y'.z'` will not be valid as the first line of the commit is the title (please refer to [balena-commit-lint](https://github.com/balena-io/resin-commit-lint) to learn more about how commits should be structured), a valid commit would be:

```
balena-supervisor: Update to v9.0.1

Update balena-supervisor from 9.0.0 to 9.0.1

Change-type: patch
Signed-off-by: Joe Developer <joe.developer@example.com>
```
