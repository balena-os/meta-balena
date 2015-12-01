# Resin.io layers for Yocto

## Description
This repository enables building resin.io for various devices.

## Layers Structure
* meta-resin-common : layer which contains common recipes for all our supported platforms.
* meta-resin-* : layer which contains recipes specific to a board / BSP.
* other files : README, COPYING, etc.

## Build configuration

### Production/Staging Builds

The 'resin-staging' DISTRO_FEATURES option allows you to enable a staging build. If a user wants a staging build, DISTRO_FEATURES_append += " resin-staging" needs to be added to local.conf.

To make it short:

* If DISTRO_FEATURES_append is not present in your local.conf and it doesn't include "resin-staging" : Production build selected (default bahavior)
* If DISTRO_FEATURES is defined local.conf and includes "resin-staging" : Staging build selected

## Devices support

### WiFi Adapters

We currently tested and provide explicit support for the following WiFi adapters:

* bcm43143 based adapters
    * Example: Official RPI WiFi adapter [link](http://thepihut.com/collections/new-products/products/official-raspberry-pi-wifi-adapter)

## Contributing

To contribute send bitbucket pull requests targeting [this](https://bitbucket.org/rulemotion/meta-resin) repository.

Please refer to: [Yocto Contribution Guidelines](https://wiki.yoctoproject.org/wiki/Contribution_Guidelines#General_Information)

## How to fix various build errors

* Supervisor fails with a log similar to:
```
Step 3 : RUN chmod 700 /entry.sh
---> Running in 445fe69866f9
operation not supported
```
This is probably because of a docker bug where, if you update kernel and don't reboot, docker gets confused. The fix is to reboot your system.
More info: http://stackoverflow.com/questions/29546388/getting-an-operation-not-supported-error-when-trying-to-run-something-while-bu
