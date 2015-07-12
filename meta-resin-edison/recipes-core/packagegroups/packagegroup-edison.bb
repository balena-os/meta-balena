SUMMARY = "Edison Package Group"
LICENSE = "Apache-2.0"

PR = "r1"

inherit packagegroup

RDEPENDS_${PN} = "\
    u-boot \
    u-boot-fw-utils \
    bluetooth-rfkill-event \
    sst-fw-bin \
    mcu-fw-load \
    mcu-fw-bin \
    "
