[![Stories in Ready](https://badge.waffle.io/resin-os/meta-resin.png?label=ready&title=Ready)](https://waffle.io/resin-os/meta-resin)
# Resin.io layers for Yocto

## Description
This repository enables building resin.io for various devices.

## Layers Structure
* meta-resin-common : layer which contains common recipes for all our supported platforms.
* meta-resin-* : layers which contain recipes specific to yocto versions.
* other files : README, COPYING, etc.

## Dependencies

* docker
* jq

## Versioning

`meta-resin` version is kept in `DISTRO_VERSION` variable. `resin-<board>` version is kept in the file called VERSION located in the root of the `resin-<board>` repository and read in the build as variable HOSTOS_VERSION.

There were two version schemes in meta-resin. One that was used before v1.2 and one that is used from 1.2 as it follows:

* Before v1.2
    * The version of `meta-resin` is in the format of 3 numbers separated by dots.
    * The version of `resin-<board>` has the same value as the version of `meta-resin` on which it is based on.
    * Ex. For `meta-resin` release 1.1.1 there can be one `resin-<board>` release 1.1.1.
* From v1.2
    * The version of `meta-resin` is in the format is 2 numbers separated by a dot.
    * The version of `resin-<board>` is in the format of 3 numbers separated by dots. The first two number are the meta-resin release while the last one is the `resin-<board>` release of the respective meta-resin release.
    * The first `resin-board` release based on a X.Y `meta-resin` release, will be X.Y.0 .
    * Ex. For `meta-resin` release 1.2 there can be `resin-<board>` releases 1.2.X.

The first versioning scheme was dropped because once meta-resin version A was relased along with the resin-board version A, the resin-board had to wait for a new meta-resin release.

We define host OS version as the `resin-<board>` version and we use this version as HOSTOS_VERSION.

## Build flags

Before bitbake-ing with meta-resin support, a few flags can be changed in the conf/local.conf from the build directory.
Editing of local.conf is to be done after source-ing.
See below for explanation on such build flags.

### Production/Staging Builds

The RESIN_STAGING_BUILD variable gets injected into DISTRO_FEATURES. If RESIN_STAGING_BUILD contains 'yes' then 'resin-staging' distro feature is added.
Based on this, recipes can decide what staging specific changes are needed. By default RESIN_STAGING_BUILD is empty which corresponds to a normal build (resis-staging won't be appended to DISTRO_FEATURE).
If user wants a staging build, to use the serial console for example, RESIN_STAGING_BUILD = "yes" needs to be added to local.conf.

To make it short:

* If RESIN_STAGING_BUILD is not present in your local.conf or it doesn't include "yes" : Production build selected (default behavior)
* If RESIN_STAGING_BUILD is defined local.conf and includes "yes" : Staging build selected

### Generation of host OS update bundles

In order to generate update resin host OS bundles, edit the build's local.conf adding:

RESINHUP = "yes"

### Configure custom network manager

By default resin uses connman on host OS to provide connectivity. If you want to change and use other providers, list your packages using NETWORK_MANAGER_PACKAGES. You can add this variable to local.conf. Here is an example:

NETWORK_MANAGER_PACKAGES = "mynetworkmanager mynetworkmanager-client"

### Customizing splash

We configure all of our initial images to produce a resin logo at boot, shutdown or reboot. But we encourage any user to go and replace that logo with their own.
All you have to do is replace the splash/resin-logo.png file that you will find in the first partition of our images (boot partition) with your own image.
NOTE: As it currently stands plymouth expects the image to be named resin-logo.png.

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
