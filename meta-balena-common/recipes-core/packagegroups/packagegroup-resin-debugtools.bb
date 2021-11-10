SUMMARY = "Resin Debug Tools Package Group"
LICENSE = "Apache-2.0"

PR = "r0"

inherit packagegroup

RDEPENDS:${PN} = " \
    e2fsprogs-mke2fs \
    lsof \
    usbutils \
    "
