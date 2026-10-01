SUMMARY = "Balena Connectivity Package Group"
LICENSE = "Apache-2.0"

PR = "r0"

inherit packagegroup

# Remove any packages added by the device integration
# layers to the BALENA_EXCLUDED_FIRMWARE variable
python () {
    # CONNECTIVITY_FIRMWARES is set below and in bbappends from
    # device integration layers, as well as by meta-balena-<distro>
    all_connectivity_firmwares = (d.getVar('CONNECTIVITY_FIRMWARES') or "").split()
    exclude_firmware = (d.getVar('BALENA_EXCLUDED_FIRMWARE') or "").split()
    current_pkg_exclude = (d.getVar('PACKAGE_EXCLUDE') or "").split()

    if not exclude_firmware:
        bb.note("No firmware was marked for exclusion")
        return

    # Remove all device integration repository
    # excluded packages from CONNECTIVITY_FIRMWARES
    updated_list = []
    for fw in all_connectivity_firmwares:
        if fw not in exclude_firmware:
            updated_list.append(fw)

    d.setVar('CONNECTIVITY_FIRMWARES', " ".join(updated_list))

    # Also add these to PACKAGE_EXCLUDE so that a build failure
    # is triggered in case they are installed through other dependencies,
    # and further steps need to be taken to ensure the exclusion.
    new_exclude_set = set(current_pkg_exclude + exclude_firmware)
    d.setVar('PACKAGE_EXCLUDE', " ".join(sorted(new_exclude_set)))

    bb.note(f"Updated CONNECTIVITY_FIRMWARES: {d.getVar('CONNECTIVITY_FIRMWARES')}")
    bb.note(f"Updated PACKAGE_EXCLUDE: {d.getVar('PACKAGE_EXCLUDE')}")
}

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
    "

RDEPENDS:${PN} = " \
    ${CONNECTIVITY_MODULES} \
    ${CONNECTIVITY_FIRMWARES} \
    ${CONNECTIVITY_PACKAGES} \
    "

