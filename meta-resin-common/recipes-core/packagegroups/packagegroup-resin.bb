SUMMARY = "Resin Package Group"
LICENSE = "Apache-2.0"

PR = "r1"

inherit packagegroup

RESIN_INIT_PACKAGE ?= "resin-init"
RESIN_MOUNTS ?= "resin-mounts"
RESIN_REGISTER ?= "docker-disk"

include packagegroup-resin.inc

# Additional packages
RDEPENDS_${PN} += " \
    docker-disk \
    dosfstools \
    hostapp-update \
    hostapp-update-hooks \
    resin-filesystem-expand \
    resin-persistent-logs \
    resin-info \
    resin-hostname \
    resin-state-reset \
    resin-device-progress \
    timeinit \
    ${@bb.utils.contains('BALENA_STORAGE', 'aufs', 'aufs-util', '', d)} \
    "
