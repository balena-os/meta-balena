#  resin-qemu repository

## Clone/Initialize the repository

There are two ways of initializing this repository:
* Clone this repository with "git clone --recursive".

or

* Run "git clone" and then "git submodule update --init --recursive". This will bring in all the needed dependencies.

## Build information

### Build flags

* Consult layers/meta-resin/README.md for info on various build flags.
(setting up serial console support for example). Build flags can be set by using the build script (barys).
See below for using the build script.

### Build this repository

* Run the build script:
  ./resin-yocto-scripts/build/barys

* You can also run barys with the -h switch to inspect the available options

## Contributing

### Issues

For issues we use an aggregated github repository available [here](https://github.com/resin-os/resinos/issues). When you create issue make sure you select the right labels.

### Pull requests

To contribute send github pull requests targeting this repository.

Please refer to: [Yocto Contribution Guidelines](https://wiki.yoctoproject.org/wiki/Contribution_Guidelines#General_Information) and try to use the commit log format as stated there. Example:
```
test.bb: I added a test

[Issue #01]

I'm going to explain here what my commit does in a way that history
would be useful.

Signed-off-by: Joe Developer <joe.developer@example.com>
```

Make sure you mention the issue addressed by a PR. See:
* https://help.github.com/articles/autolinked-references-and-urls/#issues-and-pull-requests
* https://help.github.com/articles/closing-issues-via-commit-messages/#closing-an-issue-in-a-different-repository
