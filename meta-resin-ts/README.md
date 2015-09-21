# Resin.io layer for meta-ts supported boards

## Description
This repository enables building resin.io for chosen meta-ts machines.

## Supported machines
* tsimx6

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
* URI: git://github.com/embeddedarm/meta-ts
    * branch: fido
    * revision: f91ff03e2996b37d1000534ea6d13f1a67badf2a
