# Resin.io layers for Yocto

## Description
This repository enables building resin.io for various devices.

## Layers Structure
* meta-resin-common : layer which contains common recipes for all our supported platforms.
* meta-resin-* : layer which contains recipes specific to a board / BSP.
* other files : README, COPYING, etc.

## How to build for one of the supported boards

### Determine the necessary layers for the targeted board

This repository contains layers named in the form meta-resin-${board_name} with metadata for building Resin OS for various boards. Each of this directoy has a README.md stating that layer's dependencies and revisions
that will have to used in the following steps.

### Setup the build

For example, for a beaglebone, one should to the following:

Step 1 - clone dependencies and switch to the revision indicated in meta-resin-beaglebone/README.md (following example is for the poky dependency, but one should do this for all the dependencies listed there except
the meta-resin dependency which should be already checked-out). This example assumes cloning of the dependencies is done in the same directory meta-resin has been cloned.

$ git clone git://git.yoctoproject.org/poky && cd poky && git checkout ${resivion} && cd ../

where ${revision} is the revision stated in meta-resin-beaglebone/README.md

Repeat the above step for all the dependencies.

Step 2 - configure the build

$ source poky/oe-init-build-env

Then set the Resin specific options to build/conf/local.conf file:
DISTRO = "resin-systemd"
MACHINE = "beaglebone"

the machine name can be found in meta-resin-beaglebone/README.md under "Supported machines".

Edit build/conf/bblayers.conf file and add to the BBLAYERS variable all the dependencies listed in meta-resin-beaglebone/README.md (except the poky dependencies which should already be added)

Step 3 - start the build:

$ bitbake ${image}

where ${image} is found in meta-resin-beaglebone/README.md under "Supported images".

### Production/Staging Builds

RESIN_STAGING_BUILD variable gets injected into DISTRO_FEATURES. If RESIN_STAGING_BUILD contains 'yes' then 'resin-staging' distro feature is added. Based on this, recipes can decide what staging specific changes are needed. By default RESIN_STAGING_BUILD is empty which corresponds to a normal build (resis-staging won't be appended to DISTRO_FEATURE). If user wants a staging build, RESIN_STAGING_BUILD = "yes" needs to be added to local.conf.

To make it short:

* If RESIN_STAGING_BUILD is not present in your local.conf or it doesn't include "yes" : Production build selected (default bahavior)
* If RESIN_STAGING_BUILD is defined local.conf and includes "yes" : Staging build selected

### Generation of host OS update bundles

In order to generate update resin host OS bundles, edit the build's local.conf adding:

RESINHUP = "yes"

### Configure custom network manager

By default resin uses connman on host OS to provide connectivity. If you want to change and use other providers, list your packages using NETWORK_MANAGER_PACKAGES. You can add this variable to local.conf. Here is an example:

NETWORK_MANAGER_PACKAGES = "mynetworkmanager mynetworkmanager-client"

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
