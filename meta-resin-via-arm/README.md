# Resin.io layer for VIA arm boards

## Description
This repository enables building resin.io for VIA arm machines.

## Supported machines
* vab820-quad

## Layer dependencies

This layer depends on:

* URI: ssh://git@bitbucket.org/rulemotion/meta-resin
    * layer: meta-resin-common
    * branch: master
    * revision: HEAD
* URI: git://github.org/Freescale/meta-fsl-arm
    * branch: fido
    * revision: 270599a407a36f1ff0cdbe5fcfc03f1a3a61789c
* URI: git://github.org/Freescale/meta-fsl-arm-extra
    * branch: fido
    * revision: bf73e3b4f36dc93766c432e64f4590aee13c790d
* URI: https://github.com/viaembedded/meta-via-arm/
    * branch: fido
    * revision: 8e1adf08f9144561cfbf99e78bc1016e64acaf29
