# Resin.io layer for meta-ti supported boards

## Description
This repository enables building resin.io for chosen meta-ti machines.

## Supported machines
* beaglebone

## Supported images
* resin-image-flasher

## Layer dependencies

This layer depends on:

* URI: git://git.yoctoproject.org/poky
    * layers: meta, meta-yocto, meta-yocto-bsp
    * branch: fido
    * revision: fido-13.0.0
* URI: git://github.com/openembedded/meta-openembedded
    * layers: meta-oe, meta-networking, meta-python
    * branch: fido
    * revision: 5b0305d9efa4b5692cd942586fb7aa92dba42d59
* URI: ssh://git@bitbucket.org/rulemotion/meta-resin
    * layer: meta-resin-common, meta-resin-fido, meta-resin-beaglebone
    * branch: master
    * revision: HEAD
* URI: git://git.yoctoproject.org/meta-ti
    * layers: meta-ti
    * branch: master
    * revision: 60a7bfbf96609ef6f3e084c32b2af853222b3b7e
