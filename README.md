# Resin.io layers for Yocto

## Description
This repository enables building resin.io for various devices.

## Layers Structure
* meta-resin-common : layer which contains common recipes for all our supported platforms.
* meta-resin-* : layers which contain recipes specific to yocto versions.
* other files : README, COPYING, etc.

## Dependencies

* http://www.yoctoproject.org/docs/latest/yocto-project-qs/yocto-project-qs.html#packages
* docker
* jq

## Versioning

`meta-resin` version is kept in `DISTRO_VERSION` variable. `resin-<board>` version is kept in the file called VERSION located in the root of the `resin-<board>` repository and read in the build as variable HOSTOS_VERSION.

* The version of `meta-resin` is in the format is 3 numbers separated by a dot. The patch number can have a `beta` label. e.g. 1.2.3, 1.2.3-beta1, 2.0.0-beta1.
* The version of `resin-<board>` is constructed by appending to the `meta-resin` version a `rev` label. This will have the semantics of a board revision which adapts a specific `meta-resin` version for a targeted board. For example a meta-resin 1.2.3 can go through 3 board revisions at the end of which the final version will be 1.2.3+rev3 .
* The first `resin-board` release based on a specific `meta-resin` release X.Y.Z, will be X.Y.Z+rev1 . Example: the first `resin-board` version based on `meta-resin` 1.2.3 will be 1.2.3+rev1 .
* When updating `meta-resin` version in `resin-board`, the revision will reset to 1. Ex: 1.2.3+rev4 will be updated to 1.2.4+rev1 .
* Note that the final OS version is NOT based on semver specification so parsing of such a version needs to be handled in a custom way.
* e.g. For `meta-resin` release 1.2.3 there can be `resin-<board>` releases 1.2.3+rev`X`.
* e.g. For `meta-resin` release 2.0.0-beta0 there can be `resin-<board>` releases 2.0.0-beta0+rev`X`.

We define host OS version as the `resin-<board>` version and we use this version as HOSTOS_VERSION.

## Build flags

Before bitbake-ing with meta-resin support, a few flags can be changed in the conf/local.conf from the build directory.
Editing of local.conf is to be done after source-ing.
See below for explanation on such build flags.

### Development Images

The DEVELOPMENT_IMAGE variable gets injected into DISTRO_FEATURES. If DEVELOPMENT_IMAGE = "1" then 'development-image' distro feature is added.
Based on this, recipes can decide what development specific changes are needed. By default DEVELOPMENT_IMAGE = "0" which corresponds to a normal (non-development) build (development-image won't be appended to DISTRO_FEATURE).
If user wants a build which creates development images (to use the serial console for example), DEVELOPMENT_IMAGE = "1" needs to be added to local.conf.

To make it short:

* If DEVELOPMENT_IMAGE is not present in your local.conf or it is not "1" : Non-development images will be generated (default behavior)
* If DEVELOPMENT_IMAGE is defined local.conf and its value is "1" : Development images will be generated

### Generation of host OS update bundles

In order to generate update resin host OS bundles, edit the build's local.conf adding:

RESINHUP = "yes"

### Configure custom network manager

By default resin uses NetworkManager on host OS to provide connectivity. If you want to change and use other providers, list your packages using NETWORK_MANAGER_PACKAGES. You can add this variable to local.conf. Here is an example:

NETWORK_MANAGER_PACKAGES = "mynetworkmanager mynetworkmanager-client"

### Customizing splash

We configure all of our initial images to produce a resin logo at boot, shutdown or reboot. But we encourage any user to go and replace that logo with their own.
All you have to do is replace the splash/resin-logo.png file that you will find in the first partition of our images (boot partition) with your own image.
NOTE: As it currently stands plymouth expects the image to be named resin-logo.png.

### Build flavors and selecting the docker image to be injected in the Data partition

We currently distinguish two types of builds:
* builds that are connectable to resin by including all the software bits needed for communication with resin infrastructure
* builds that are not connectable to resin and are only meant for testing docker and other resinOS features on supported boards

The switch for these types is done based on a build variable `RESIN_CONNECTABLE` which by default is currently set (=1).

#### RESIN_CONNECTABLE = "1" [default]

In this case, docker-resin-supervisor-disk will be used as a docker-disk provider. All the needed services for connecting the device to resin will be installed (systemd services, VPN configuration etc.). By default the systemd services which are part of communicating to resin are enabled. This default behavior can be customized using `RESIN_CONNECTABLE_ENABLE_SERVICES` build variable.

As well, by default, the docker resin-supervisor image will be preloaded in the Data partition. This behavior can be modified using TARGET_REPOSITORY/TARGET_TAG build variables. This leaves the possibility of creating a build without provisioning the supervisor image or creating one with all the supervisor services but with a custom image. TARGET_REPOSITORY/TARGET_TAG are decribed below.

Example: having a connectable image with services enabled and supervisor docker image preloaded - nothing to be done to build's `local.conf` as these imply default values of all the variables.

Example: having a connectable image with services disabled and supervisor docker image preloaded - add/set `RESIN_CONNECTABLE_ENABLE_SERVICES = "0"` to build's `local.conf`.

Example: having a connectable image with services disabled and no docker image preloaded - add/set `RESIN_CONNECTABLE_ENABLE_SERVICES = "0"`, `TARGET_REPOSITORY = ""` and `TARGET_TAG = ""`  to build's `local.conf`.

Example: having a connectable image with services disabled and custom docker image preloaded - add/set `RESIN_CONNECTABLE_ENABLE_SERVICES = "0"`, `TARGET_REPOSITORY = "mycustomimage"` and `TARGET_TAG = "1.0"`  to build's `local.conf`.

Connectable images will have a tool for managing the resin services installed on the target called `resin-connectable`. Check help message by running `resin-connectable -h` for more information.

#### RESIN_CONNECTABLE = "0"

In this case, docker-custom-disk will be used as a docker-disk provider. All the services and software bits responsible for communicating with resin infrastructure will not be installed. In this case `RESIN_CONNECTABLE_ENABLE_SERVICES` has no effect on the build as it only applies for connectable builds.

Without any other configuration, the build will leave the Data partition without any image preloaded. In addition to this, two other variables can be used to inject a specific dockerhub image:
* TARGET_REPOSITORY - the image name wanted to be injected
* TARGET_TAG - the image tag wanted to be injected. If not defined it will default to `latest`. Otherwise will use the specified value.

Example: having a non-connectable image without any docker image preloaded - add/set `RESIN_CONNECTABLE="0"` to build's `local.conf`.

Example: having a non-connectable image with ubuntu:latest docker image preloaded - add/set `RESIN_CONNECTABLE = "0"` and `TARGET_REPOSITORY = "ubuntu"` to build's `local.conf`.

Example: having a non-connectable image with ubuntu:15:10 docker image preloaded - add/set `RESIN_CONNECTABLE = "0"`, `TARGET_REPOSITORY = "ubuntu"` and `TARGET_TAG = "15.04"` to build's `local.conf`.

Hint: Modifing any of the TARGET_* variables, will retrigger the generation of the Data partition without any issues but, if `RESIN_CONNECTABLE` is changed in a working build (not one from scatch), the user will need to cleansstate the docker-image providers issuing a command similar to `bitbake docker-custom-disk -c cleansstate ; bitbake docker-resin-supervisor-disk -c cleansstate`. Failing to do so, while changing `RESIN_CONNECTABLE` in a working build, will result in a build error similar to:

> ERROR: The recipe docker-custom-disk is trying to install files into a shared area when those files already exist. Those files and their manifest location are:
>    ???/build/tmp/sysroots/beaglebone/sysroot-providers/docker-disk
>  Matched in manifest-beaglebone-docker-resin-supervisor-disk.populate_sysroot
> Please verify which recipe should provide the above files.
> The build has stopped as continuing in this scenario WILL break things, if not now, possibly in the future (we've seen builds fail several months later). If the system knew how to recover from this automatically
> it would however there are several different scenarios which can result in this and we don't know which one this is. It may be you have switched providers of something like virtual/kernel (e.g. from linux-yocto t
> o linux-yocto-dev), in that case you need to execute the clean task for both recipes and it will resolve this error. It may be you changed DISTRO_FEATURES from systemd to udev or vice versa. Cleaning those recipe
> s should again resolve this error however switching DISTRO_FEATURES on an existing build directory is not supported, you should really clean out tmp and rebuild (reusing sstate should be safe). It could be the ov
> erlapping files detected are harmless in which case adding them to SSTATE_DUPWHITELIST may be the correct solution. It could also be your build is including two different conflicting versions of things (e.g. blue
> z 4 and bluez 5 and the correct solution for that would be to resolve the conflict. If in doubt, please ask on the mailing list, sharing the error and filelist above.
> ERROR: If the above message is too much, the simpler version is you're advised to wipe out tmp and rebuild (reusing sstate is fine). That will likely fix things in most (but not all) cases.

## Devices support

### WiFi Adapters

We currently tested and provide explicit support for the following WiFi adapters:

* bcm43143 based adapters
    * Example: Official RPI WiFi adapter [link](http://thepihut.com/collections/new-products/products/official-raspberry-pi-wifi-adapter)

## Contributing

To contribute send github pull requests targeting [this](https://github.com/resin-os/meta-resin) repository.

Please refer to: [Yocto Contribution Guidelines](https://wiki.yoctoproject.org/wiki/Contribution_Guidelines#General_Information) and try to use the commit log format as stated there. Example:
```
test.bb: I added a test

[Issue #01]

I'm going to explain here what my commit does in a way that history
would be useful.

Signed-off-by: Joe Developer <joe.developer@example.com>
```


## How to fix various build errors

* Supervisor fails with a log similar to:
```
Step 3 : RUN chmod 700 /entry.sh
---> Running in 445fe69866f9
operation not supported
```
This is probably because of a docker bug where, if you update kernel and don't reboot, docker gets confused. The fix is to reboot your system.
More info: http://stackoverflow.com/questions/29546388/getting-an-operation-not-supported-error-when-trying-to-run-something-while-bu
