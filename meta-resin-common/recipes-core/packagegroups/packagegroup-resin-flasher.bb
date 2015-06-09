SUMMARY = "Resin flasher Package Groups"
LICENSE = "Apache-2.0"

PR = "r1"

inherit packagegroup

RDEPENDS_${PN} = " \
    linux-firmware-ath9k \
    linux-firmware-ralink \
    linux-firmware-rtl8192cu \
    kernel-modules \
    resin-init-flasher \
    vpn-init \
    "
