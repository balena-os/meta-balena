SUMMARY = "Resin Flasher Package Group"
LICENSE = "Apache-2.0"

PR = "r1"

inherit packagegroup

RDEPENDS_${PN} = " \
    kernel-modules \
    resin-init-flasher \
    "
