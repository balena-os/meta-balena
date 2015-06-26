SUMMARY = "Resin Connectivity Package Group"
LICENSE = "Apache-2.0"

PR = "r0"

inherit packagegroup

CONNECTIVITY_MODULES = ""

CONNECTIVITY_FIRMWARES = " \
    linux-firmware-ath9k \
    linux-firmware-ralink \
    linux-firmware-rtl8192cu \
    linux-firmware-bcm43143 \
    "

CONNECTIVITY_PACKAGES = " \
    connman \
    connman-client \
    wireless-tools \
    vpn-init \
    "

RDEPENDS_${PN} = " \
    ${CONNECTIVITY_MODULES} \
    ${CONNECTIVITY_FIRMWARES} \
    ${CONNECTIVITY_PACKAGES} \
    "
