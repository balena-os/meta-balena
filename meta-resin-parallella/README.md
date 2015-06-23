# Resin.io layer for meta-parallella supported boards

## Description
This repository enables building resin.io for chosen Parallella machines.

## Supported machines
* parallella-hdmi-resin

## Layer dependencies

This layer depends on:

* URI: ssh://git@bitbucket.org/rulemotion/meta-resin
    * layer: meta-resin-common
    * branch: master
    * revision: HEAD
* URI: git://github.org/nathanrossi/meta-parallella
    * branch: master
    * revision: 1bb8172879700c388ce93bcb722e15e6b1cbaafc
* URI: git://github.org/Xilinx/meta-xilinx
    * branch: master
    * revision: cd67eae1c63c64a2edd9560aec6d0b78fd7549cb
