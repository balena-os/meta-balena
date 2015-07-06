# Resin.io layers for Yocto

## Description
This repository enables building resin.io for various devices.

## Layers Structure
* meta-resin-common : layer which contains common recipes for all our supported platforms.
* meta-resin-* : layer which contains recipes specific to a board / BSP.
* other files : README, COPYING, etc.

## Build configuration

### Production/Staging Builds

RESIN_STAGING_BUILD variable gets injected into DISTRO_FEATURES. If RESIN_STAGING_BUILD contains 'yes' then 'resin-staging' distro feature is added. Based on this, recipes can decide what staging specific changes are needed. By default RESIN_STAGING_BUILD is empty which corresponds to a normal build (resis-staging won't be appended to DISTRO_FEATURE). If user wants a staging build, RESIN_STAGING_BUILD = "yes" needs to be added to local.conf.

To make it short:

* If RESIN_STAGING_BUILD is not present in your local.conf or it doesn't include "yes" : Production build selected (default bahavior)
* If RESIN_STAGING_BUILD is defined local.conf and includes "yes" : Staging build selected

## Devices support

### WiFi Adapters

We currently tested and provide explicit support for the following WiFi adapters:

* bcm43143 based adapters
    * Example: Official RPI WiFi adapter [link](http://thepihut.com/collections/new-products/products/official-raspberry-pi-wifi-adapter)

## Contributing

To contribute send bitbucket pull requests targeting [this](https://bitbucket.org/rulemotion/meta-resin) repository.

Please refer to: [Yocto Contribution Guidelines](https://wiki.yoctoproject.org/wiki/Contribution_Guidelines#General_Information)
