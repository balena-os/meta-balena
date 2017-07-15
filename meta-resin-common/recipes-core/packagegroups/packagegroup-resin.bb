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
    resin-filesystem-expand \
    resin-persistent-logs \
    resin-info \
    resin-hostname \
    resin-state-reset \
    resinhup \
    aufs-util \
    ${@bb.utils.contains('RESIN_CONNECTABLE', '1', 'resin-connectable', '', d)} \
    ${@bb.utils.contains('RESIN_CONNECTABLE', '1', 'resin-provisioner', '', d)} \
    "
