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

# Contribute to balenaOS

There are many ways to contribute to balenaOS, based on your skills and interests. Whether you are an embedded linux expert or a casual user, you can find areas where you can make a big difference!


## Testing and Bug Reports

Nobody likes buggy software! If you encounter any problems while using balenaOS, you can submit an [issue on github](https://github.com/balena-os/meta-balena/issues). Please include as much information about the problem as possible.

The same applies for the [balenaOS board support](https://github.com/balena-os?utf8=%E2%9C%93&query=balena-) repositories as well, if you are reporting issues specific to particular hardware.


## Submitting Fixes

If you check out the [issues](https://github.com/balena-os/meta-balena/issues) reported for balenaOS, and you find any that you feel you’d like to fix, you can submit a [Pull Request](https://help.github.com/articles/about-pull-requests/) with your proposed change. Please observe the [Contribution Guidelines](https://github.com/balena-os/meta-balena/blob/master/CONTRIBUTING.md).

The same applies for the [balenaOS board support](https://github.com/balena-os?utf8=%E2%9C%93&query=balena-) repositories as well, if you are fixing issues specific to particular hardware.


## Support for Additional Boards

BalenaOS is intended to work with any kind of board that fulfills some basic hardware requirements (see our Supported Boards list for [currently supported devices](https://www.balena.io/docs/reference/hardware/devices/)). If you have any other board that you’d like to see on that list, please check our [board support contribution guide](https://github.com/balena-os/meta-balena/blob/master/contributing-device-support.md) for more details. You’ll need to be familiar with [Yocto](http://www.yoctoproject.org/), and the board you are adding.


## Documentation

BalenaOS is quickly evolving, and having good documentation that keeps up with the changes is crucial. If you find any information that is incomplete or missing, you can submit improvements to our documentation on Github!

## Tutorials

Tutorials, how-to guides, and blog posts regarding using balenaOS are always welcome. This would help us figure out how to make balenaOS more usable for everyone, and also help new users to get started. If you have any tutorials and guides, please let us know in the [balena forums](https://forums.balena.io/).

