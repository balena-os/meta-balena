SUMMARY = "Resin Package Group"
LICENSE = "Apache-2.0"

PR = "r1"

inherit packagegroup

RESIN_INIT_PACKAGE ?= "resin-init"
RESIN_MOUNTS ?= "resin-mounts"

include packagegroup-resin.inc

# Additional packages
RDEPENDS_${PN} += " \
    resin-supervisor \
    resin-btrfs-balance \
    resin-btrfs-expand \
    resin-logs \
    resin-extend-expand \
    resin-info-tty \
    "
