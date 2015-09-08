# Resin.io layer for Intel boards

## Description
This repository enables building resin.io for Intel machines.

## Supported machines
* nuc

## Layer dependencies

This layer depends on:

* URI: ssh://git@bitbucket.org/rulemotion/meta-resin
    * layer: meta-resin-common
    * branch: master
    * revision: HEAD
* URI: git://git.yoctoproject.org/meta-intel
    * layer: meta-intel, meta-intel/meta-nuc
    * branch: fido
    * revision: 28e8017ab8ba4f4d9e3fe5a5346bf31b3334bbbb
