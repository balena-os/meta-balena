SUMMARY = "Balena Connectivity Package Group"
LICENSE = "Apache-2.0"

PR = "r0"

inherit packagegroup

# By default balena uses networkmanager
NETWORK_MANAGER_PACKAGES ?= "networkmanager"

CONNECTIVITY_MODULES = ""

# We no longer ship bluetooth
# firmware by default

BLUETOOTH_FIRMWARE = " \
    linux-firmware-rtl8723b-bt \
"

# Defined in meta-balena-common/conf/distro/include/balena-os.inc
CONNECTIVITY_FIRMWARES ?= " \
   ${CORE_CONNECTIVITY_FIRMWARES}
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
    "

RDEPENDS:${PN} = " \
    ${CONNECTIVITY_MODULES} \
    ${CONNECTIVITY_FIRMWARES} \
    ${CONNECTIVITY_PACKAGES} \
    "
