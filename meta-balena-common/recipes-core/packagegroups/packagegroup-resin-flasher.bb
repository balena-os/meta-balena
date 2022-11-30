SUMMARY = "Resin Flasher Package Group"
LICENSE = "Apache-2.0"

PR = "r1"

inherit packagegroup

BALENA_INIT_PACKAGE ?= "balena-init-flasher"
BALENA_MOUNTS ?= "resin-mounts-flasher"
BALENA_REGISTER ?= "resin-device-register"

include packagegroup-resin.inc
