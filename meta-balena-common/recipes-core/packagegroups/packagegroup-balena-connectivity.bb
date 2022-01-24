SUMMARY = "Balena Connectivity Package Group"
LICENSE = "Apache-2.0"

PR = "r0"

inherit packagegroup

# By default balena uses networkmanager
NETWORK_MANAGER_PACKAGES ?= "networkmanager"

CONNECTIVITY_MODULES = ""

CONNECTIVITY_FIRMWARES ?= " \
    linux-firmware-ath9k \
    linux-firmware-mt7601u \
    linux-firmware-ralink \
    linux-firmware-rtl8192cu \
    linux-firmware-rtl8192su \
    linux-firmware-rtl8723 \
    linux-firmware-rtl8723b-bt \
    "

CONNECTIVITY_PACKAGES = " \
    ${NETWORK_MANAGER_PACKAGES} \
    avahi-daemon \
    balena-net-connectivity-wait \
    dnsmasq \
    dropbear \
    openvpn \
    openssh \
    balena-proxy-config \
    usb-modeswitch \
    iw \
    bluez5-noinst-tools \
    "

RDEPENDS:${PN} = " \
    ${CONNECTIVITY_MODULES} \
    ${CONNECTIVITY_FIRMWARES} \
    ${CONNECTIVITY_PACKAGES} \
    "
