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
   ${CORE_CONNECTIVITY_FIRMWARES} \
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

# Filter-out linux-firmware packages
# based on the interfaces available for
# the device-type built.
# The device-type repository specifies
# the available interfaces using MACHINE_FEATURES.
# Connectivity packages - interfaces mapping
# is set by conf/distro/include/balena-os.inc
python () {
    # All connectivity firmwares that can be installed by meta-balena
    all_connectivity_firmwares = d.getVar('CONNECTIVITY_FIRMWARES')
    bb.note(f"Initial list of CONNECTIVITY_FIRMWARES: {all_connectivity_firmwares}")
    if not all_connectivity_firmwares:
        return

    # Split into an iterateable list
    current_firmware_list = all_connectivity_firmwares.split()
    machine_features = (d.getVar('MACHINE_FEATURES') or "").split()

    # Mapping of firmware packages to hardware features (M.2, USB, etc)
    fw_feature_map = d.getVarFlags('LINUX_FIRMWARE_PACKAGES') or {}

    keep_list = []

    for pkg in current_firmware_list:
        # Hardware interfaces associated with this package
        # i.e 'ath9k' is in features_USB', 'features_PCIE' and in 'features_MINI_PCIE'
        associated_features = []
        for feature_name, pkg_list_str in fw_feature_map.items():
            if pkg in pkg_list_str.split():
                associated_features.append(feature_name)

        # If the package does not belong to any interface, we keep it to avoid
        # accidentaly discarding any essential packages that are installed
        # by the device repository. If the device repository installs
        # a linux-firmware package which does not belong to the Connectivity or Storage
        # categories, it will be blacklisted by the firmware exclusion and surfaced
        # by the final audit.
        if not associated_features:
            keep_list.append(pkg)
            continue

        # Check if MACHINE_FEATURES for this DT includes at least one of the required features
        has_hardware_support = False
        for feat in associated_features:
            if feat in machine_features:
                has_hardware_support = True
                break

        if has_hardware_support:
            # DT has the physical interface (i.e USB, M.2, etc) needed for this firmware
            # sp we keep the current package
            keep_list.append(pkg)
        else:
            # None the package's supported interfaces is present in MACHINE_FEATURES
            bb.note(f"Policy: Stripping {pkg} - Machine lacks any of: {', '.join(associated_features)}")

    updated_connectivity_firmwares = " ".join(keep_list)
    d.setVar('CONNECTIVITY_FIRMWARES', updated_connectivity_firmwares)
    bb.note(f"Updated list of CONNECTIVITY_FIRMWARES: {updated_connectivity_firmwares}")
}
