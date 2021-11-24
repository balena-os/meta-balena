SUMMARY = "Resin Connectivity Package Group"
LICENSE = "Apache-2.0"

PR = "r0"

inherit packagegroup

# By default resin uses networkmanager
NETWORK_MANAGER_PACKAGES ?= "networkmanager"

CONNECTIVITY_MODULES = ""

CONNECTIVITY_FIRMWARES ?= " \
    linux-firmware-ath9k \
    linux-firmware-mt7601u \
    linux-firmware-ralink \
    linux-firmware-rtl8192cu \
    linux-firmware-rtl8192su \
    "

CONNECTIVITY_PACKAGES = " \
    ${NETWORK_MANAGER_PACKAGES} \
    avahi-daemon \
    dnsmasq \
    openvpn \
    resin-proxy-config \
    usb-modeswitch \
    iw \
    "

RDEPENDS_${PN} = " \
    ${CONNECTIVITY_MODULES} \
    ${CONNECTIVITY_FIRMWARES} \
    ${CONNECTIVITY_PACKAGES} \
    "
