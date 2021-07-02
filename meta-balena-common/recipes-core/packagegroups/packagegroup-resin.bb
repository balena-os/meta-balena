SUMMARY = "Resin Package Group"
LICENSE = "Apache-2.0"

PR = "r1"

inherit packagegroup

BALENA_INIT_PACKAGE ?= "resin-init"
BALENA_MOUNTS ?= "resin-mounts"
BALENA_REGISTER ?= "resin-supervisor"
BALENA_SUPERVISOR ?= "resin-supervisor"

include packagegroup-resin.inc

# Additional packages
RDEPENDS_${PN} += " \
    dosfstools \
    mobynit \
    docker-disk \
    hostapp-update \
    hostapp-extensions-update \
    hostapp-update-hooks \
    resin-filesystem-expand \
    resin-persistent-logs \
    resin-info \
    resin-hostname \
    resin-state-reset \
    resin-device-progress \
    timeinit \
    systemd-zram-swap \
    ${@bb.utils.contains('BALENA_STORAGE', 'aufs', 'aufs-util-auplink', '', d)} \
    ${BALENA_SUPERVISOR} \
    "
