# Resin.io layer for edison boards

## Description
This repository enables building resin.io for edison machine.

## Supported machines
* edison

## Layer dependencies

This layer depends on:

* URI: git://git.yoctoproject.org/poky
    * branch: daisy
    * revision: 39d2ca4e34e9c7a67e4df56cfb49dcc106bf397e
* URI: git://github.com/openembedded/meta-openembedded
    * layers: meta, meta-networking, meta-python
    * branch: daisy
    * revision: HEAD
* URI: https://downloadcenter.intel.com
    * version: Intel Edison Software Release 2.1 (ww18-15)
* URI: git://git.yoctoproject.org/meta-intel-iot-middleware
    * branch: daisy
    * revision: HEAD
