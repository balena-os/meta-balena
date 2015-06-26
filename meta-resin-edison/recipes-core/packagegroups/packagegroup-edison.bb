SUMMARY = "Edison Package Group"
LICENSE = "Apache-2.0"

PR = "r1"

inherit packagegroup

RDEPENDS_${PN} = "\
    u-boot \
    u-boot-fw-utils \
    bcm43340-fw \
    bcm43340-bt \
    bluetooth-rfkill-event \
    bcm43340-mod \
    sst-fw-bin \
    mcu-fw-load \
    mcu-fw-bin \
    "
