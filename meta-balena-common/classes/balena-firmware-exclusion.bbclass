python () {
    global driver_categories
    global skip_list

    # Categorized using https://github.com/openSUSE/kernel-firmware-tools/blob/main/topics.list
    # and https://github.com/openSUSE/kernel-firmware-tools/blob/main/topicdefs
    driver_categories = {
        "GPU": [
            "amdgpu",
            "isp",
            "tegra-vic",
            "nouveau",
            "radeon",
            "i915",
            "xe",
            "adreno",
            "amdxdna",
            "intel_vpu",
            "amphion",
            "powervr",
            "panthor",
        ],
        "Audio": [
            "snd-korg1212",
            "snd-maestro3",
            "snd-ymfpci",
            "emi26",
            "emi62",
            "snd-sb16-csp",
            "snd-wavefront",
            "snd-hda-codec-ca0132",
            "snd_soc_sst_acpi",
            "snd_soc_catpt",
            "snd_soc_avs",
            "snd_intel_sst_core",
            "snd-soc-skl",
            "cs35l41",
            "cs35l41_hda",
            "cs35l56",
            "cs42l43",
            "cs42l45",
            "mtk-sof",
            "qcom-sc8280xp",
            "qcom-qcs6490",
            "qcom-qcs8300",
            "qcom-qcs9100",
            "qcom-sm8550",
            "qcom-sm8650",
            "qcom-x1e80100",
            "ti-tas2781",
            "ti-tas2563",
            "qcm6490",
            "qcs615",
            "sm8450",
            "sm8750",
        ],
        "Video": [
            "atomisp",
            "ipu3-imgu",
            "intel-ipu6-isys",
            "intel-ipu7-isys",
            "mei-vsc-hw",
            "dvb-ttusb-budget",
            "cpia2",
            "dabusb",
            "vicam",
            "cx231xx",
            "cx23418",
            "cx23885",
            "cx23840",
            "dvb-ttpci",
            "xc4000",
            "xc5000",
            "dib0700",
            "lgs8gxx",
            "ti-vpe",
            "tlg2300",
            "drxk",
            "s5p-mfc",
            "as102",
            "it9135",
            "smsmdtv",
            "mtk-vpu",
            "venus",
            "iris",
            "meson-vdec",
            "mt8196",
            "mga",
            "r128",
            "s2255drv",
            "go7007",
            "rk3399-dptx",
            "cdns-mhdp",
            "lt9611uxc",
            "wave5",
            "wave6",
            "ast",
        ],
        "Connectivity": [
            "sdx61",
            "sdx35",
            "ar9170",
            "ath9k_htc",
            "ath6kl",
            "ar5523",
            "carl9170",
            "wil6210",
            "ath10k",
            "ath11k",
            "ath12k",
            "bnx2x",
            "bnx2",
            "brcmsmac",
            "brcmfmac",
            "cxgb3",
            "cxgb4",
            "mt7601u",
            "mt76x0",
            "mt76x2e",
            "mt76x2u",
            "mt7615e",
            "mt7622",
            "mt7663",
            "mt7915e",
            "mt7920",
            "mt7921",
            "mt7922",
            "mt7925",
            "mt7988",
            "mtk-2p5ge",
            "mt7996e",
            "mtk_wed",
            "mwifiex",
            "orinoco",
            "slicoss",
            "sxg",
            "e100",
            "acenic",
            "tg3",
            "starfire",
            "tehuti",
            "typhoon",
            "myri_sbus",
            "netxen_nic",
            "rt61pci",
            "as21xxx",
            "en8811h",
            "an8811hb",
            "airoha-npu-7581",
            "airoha-npu-7583",
            "vxge",
            "myri10ge",
            "cw1200",
            "wilc1000",
            "ice",
            "nfp",
            "mlxsw_spectrum",
            "prestera",
            "qla2xxx",
            "ib_qib",
            "qed",
            "BFA/BNA",
            "rt2800pci",
            "rt2860sta",
            "rt2800usb",
            "rt2870sta",
            "rtl8192e",
            "r8712u",
            "rtl8192ce",
            "rtl8192cu",
            "rtl8192se",
            "rtl8192de",
            "rtl8192du",
            "rtl8723e",
            "rtl8723be",
            "rtl8723de",
            "r8723au",
            "rtl8188ee",
            "rtl8188eu",
            "rtl8821ae",
            "rtl8822be",
            "rtw88",
            "rtw89",
            "rtl8192ee",
            "rtl8723bs",
            "rtl8xxxu",
            "r8169",
            "r8152",
            "rt1320",
            "wl12xx",
            "wl18xx",
            "cc33xx",
            "ueagle-atm",
            "kaweth",
            "rt73usb",
            "vt6656",
            "rsi",
            "atusb",
            "liquidio",
            "iwlwifi",
            "libertas",
            "mwl8k",
            "mwlwifi",
            "wl1251",
            "hfi1",
            "qcom_q6v5_mss",
            "ixp4xx-npe",
            "pcnet_cs",
            "3c589_cs",
            "3c574_cs",
            "smc91c92_cs",
            "mscc-phy",
            "wfx",
        ],
        "Bluetooth": [
            "ath3k",
            "DFU",
            "Atheros",
            "btusb",
            "qca",
            "btqca",
            "amlogic",
            "BCM-0bb4-0306",
            "btmtk_usb",
            "btmtk",
            "TI_ST",
            "btnxpuart"
        ],
        "Storage": [
            "isci",
            "qla1280",
            "qlogicpti",
            "xhci-tegra",
            "advansys",
            "ene-ub6250",
            "xhci-rcar",
            "imx-sdma",
            "microcode_amd"
        ],
        "Misc": [
            "qat",
            "ish",
            "qcom_q6v5_pas",
            "qaic",
            "qdu100",
            "qcom-geni-se",
            "knav_qmss_queue",
            "fsl-mc",
            "dsp56k",
            "cassini",
            "yam",
            "serial_cs",
            "usbdux/usbduxfast/usbduxsigma",
            "amd_pmf",
            "ccp",
            "nitrox",
            "inside-secure",
            "rvu_cptpf",
            "nxp-sr1xx",
            "Mont-TSSE",
            "bmi260",
            "pcie-rcar-gen4",
            "keyspan",
            "keyspan_pda",
            "ti_usb_3410_5052",
            "whiteheat",
            "io_edgeport",
            "io_ti",
            "rp2",
            "mxu11x0",
            "mxuport",
            "mtk_scp",
        ]
    }

    # These are either generic or
    # contain files which are not firmware
    # binaries.
    skip_list = [
        "linux-firmware-license",
        "linux-firmware-dev",
        "linux-firmware-doc",
        "linux-firmware-locale",
        "linux-firmware",
        "linux-firmware-dbg",
        "linux-firmware-staticdev"
    ]
}

# Parse WHENCE files to obtain the list of firmware files
# for each driver. All files matching *WHENCE
# because we have to add some corrections to the
# upstream listing.
def parse_whences(d, whence_paths):
    import os
    import re

    # Extract driver name
    def get_driver_id(line):
        match = re.search(r'Driver:\s*([^\s]+)', line)
        if match:
            # WHENCE format is 'Driver: driver-name'
            return match.group(1).rstrip(':').strip()
        return None

    # Firmware files are listed after "File:" or "RawFile:", one file per line
    def get_firmware_path(line):
        return line.split(':', 1)[1].strip()

    # Links are in the format "Link: <source> -> <target>"
    def get_link_paths(line):
        return [p.strip() for p in line.split(':', 1)[1].split('->')]

    whence_map = {}

    for path in whence_paths:
        with open(path, 'r') as f:
            current_driver = None
            for line in f:
                line = line.strip()

                # Skip License entries
                if not line or line.startswith("Licence:"):
                    continue

                # Assign the File, RawFile or Link to the driver it's listed under
                if line.startswith("Driver:"):
                    try:
                        current_driver = get_driver_id(line)
                        if current_driver and current_driver not in whence_map:
                            whence_map[current_driver] = []
                    except (AttributeError, IndexError):
                        current_driver = None

                elif current_driver:
                    if line.startswith("File:") or line.startswith("RawFile:"):
                        whence_map[current_driver].append(get_firmware_path(line))

                    elif line.startswith("Link:"):
                        for lf in get_link_paths(line):
                            if lf not in whence_map[current_driver]:
                                whence_map[current_driver].append(lf)

    return whence_map

# Checks the files listed in each package
# created by the linux-firmware recipe
# and matches them to a driver.
# All drivers are classified already and thus each
# package will fall into one or more
# categories, based on the files it ships.
# Packages which fall into non-essential
# categories will be saved into a list
# and discarded from the image using BAD_RECOMMENDATIONS.
# This last step is performed by image-balena.bbclass.
def check_package_drivers(d, whence_map):
    import os
    import fnmatch
    global driver_categories
    global skip_list

    packages = (d.getVar('PACKAGES') or "").split()
    fw_roots = [os.path.join(d.getVar('nonarch_base_libdir'), 'firmware'), '/usr/lib/firmware', '/lib/firmware']
    image_dir = d.getVar('D')

    # Machine features as defined by the the device repository
    # firmware to feature mapping is done at meta-balena level
    # in conf/include/balena-os.inc
    machine_features = (d.getVar('MACHINE_FEATURES') or "").split()
    fw_feature_map = d.getVarFlags('LINUX_FIRMWARE_PACKAGES') or {}

    # Firmware file to driver mapping is used
    # for determining the categories (i.e GPU, Audio, etc)
    # for each linux-firmware package.
    known_files = []
    for drv, files in whence_map.items():
        for f in files:
            # Searchable list of firmware files and their associated drivers
            # as described in WHENCE
            known_files.append((f, drv))

    uncategorized_drivers = []
    # Packages and set of categories
    nonessential_packages = {}
    # All available packages and the size of the files in them
    all_packages_data = {}

    bb.note("\nPackages and Drivers Mapping:")
    for pkg in packages:
        # Skip license packages, they are not useful for
        # categorization
        if pkg in skip_list or "license" in pkg: continue

        # Files included in package, as set in the linux-firmware recipe(s)
        package_files = d.getVar(f'FILES:{pkg}')
        if not package_files: continue

        # Drivers associated to the files in the current package
        pkg_drivers = set()
        pkg_size = 0

        # File paths for current package
        package_contents = []

        # FILES:${PN} contains file paths or patterns
        for pattern in package_files.split():
            clean_p = pattern

            # Strip absolute path for each file path or pattern in FILES:${PN} and
            # try match it to the relative path mentioned in WHENCE
            for root in fw_roots:
                if pattern.startswith(root):
                    # '/lib/firmware/qca/fw.bin' becomes 'qca/fw.bin
                    clean_p = os.path.relpath(pattern, root)

                    # image_dir is ${D}, and this task is run after do_firmware_compression()
                    full_pattern_path = os.path.join(image_dir, pattern.lstrip('/'))
                    dir_to_search = os.path.dirname(full_pattern_path)
                    file_pattern = os.path.basename(full_pattern_path)

                    if os.path.exists(dir_to_search):
                        for f_name in os.listdir(dir_to_search):
                            # linux-firmware bbappend uses * to account for
                            # compressed firmware in FILES:${PN}
                            if fnmatch.fnmatch(f_name, file_pattern):
                                f_path = os.path.join(dir_to_search, f_name)
                                if os.path.isfile(f_path) and not os.path.islink(f_path):
                                    pkg_size += os.path.getsize(f_path)
                    break

            clean_p = clean_p.lstrip('./')
            package_contents.append(clean_p)

            # Check if stripped file entry exists in the firmware-to-driver mapping
            # and if it does, associate the package to the driver
            for fw_file, driver in known_files:
                if (fnmatch.fnmatch(fw_file, clean_p) or clean_p in fw_file or fw_file in clean_p):
                    bb.note(f"Mapping File: {clean_p} (in {pkg}) to driver: {driver}")
                    pkg_drivers.add(driver)

        if pkg_drivers:
            if pkg not in all_packages_data:
                all_packages_data[pkg] = {"categories": set(), "size": pkg_size}

            # Stores every interface supported by this package, i.e 'features_USB'
            associated_features = []

            for feature_name, package_list_string in fw_feature_map.items():
                if pkg in package_list_string.split():
                    associated_features.append(feature_name)

            # Avoid excluding packages added by the BSP.
            # This check focuses on the packages added by meta-balena
            # by default
            has_hardware_support = True

            if associated_features:
                matching_features = []

                # Check if any of the interfaces supported by this package
                # is set in MACHINE_FEATURES
                for f in associated_features:
                    if f in machine_features:
                        matching_features.append(f)

                if matching_features:
                    # At least one interface is set in MACHINE_FEATURES
                    has_hardware_support = True
                    bb.note(f"Package {pkg} is essential - supported by: {', '.join(matching_features)}")
                else:
                    # MACHINE_FEATURES contains none of the supported interfaces
                    has_hardware_support = False

            if not has_hardware_support:
                # Package is mapped to at least one feature, so it is installed by meta-balena. But MACHINE_FEATURES does not include it
                bb.note(f"Package {pkg} is non-essential: None of its interfaces ({', '.join(associated_features)}) present in MACHINE_FEATURES")

                if pkg not in nonessential_packages:
                    nonessential_packages[pkg] = set()

                # Include exclusion reason
                nonessential_packages[pkg].add(f"UnsupportedInterfaces({','.join(associated_features)})")

            elif not associated_features:
                # Firmware package is not categorized,
                # which means it is installed by device repository,
                # not by meta-balena for all devices.
                # We only filter out packages installed by meta-balena
                # through hardware mapping
                bb.note(f"Package {pkg} is not installed by meta-balena for all devices (no hardware interface mapping found)")

            bb.note(f"Package: {pkg} (Size: {pkg_size} bytes)")

            for drv in sorted(pkg_drivers):
                category = "Unknown"
                # Check if the drivers in this package are classified
                # and assign their category, i.e GPU, audio, video.
                # A package may contain firmware for different drivers,
                # and not all drivers may belong to the same category
                for cat, drvs in driver_categories.items():
                    if drv in drvs:
                        category = cat
                        break

                all_packages_data[pkg]["categories"].add(category)
                bb.note(f"  Driver: {drv} - Category: {category}")

                # Each driver should be listed above in a category,
                # otherwise the build will fail
                if category == "Unknown":
                    uncategorized_drivers.append((drv, pkg))
                # We allow Storage and Connectivity by default. But we may switch to layers,
                # which could contain bluetooth packages too
                elif category not in ["Connectivity", "Storage"]:
                    if pkg not in nonessential_packages:
                        nonessential_packages[pkg] = set()
                    nonessential_packages[pkg].add(category)
        else:
            bb.fatal(f"Package: {pkg} has no matches in WHENCE. Please check the files it ships and add them to the extra_WHENCE")
            for item in sorted(package_contents):
                if item not in [".", ""]: bb.note(f"  - File/Pattern: {item}")

    # Save the non essential firmware packages list to DEPLOY_DIR_IMAGE.
    # When the rootfs is generated, these listed packages will be added
    # to BAD_RECOMMENDATIONS.
    # This last step is performed by image-balena.bbclass.
    deploy_dir = d.getVar('DEPLOY_DIR_IMAGE')
    if deploy_dir:
        bb.utils.mkdirhier(deploy_dir)

        if nonessential_packages:
            # Non essential packages list is used during the final audit of the image manifest
            output_file_nonessential = os.path.join(deploy_dir, "nonessential_firmware.txt")
            with open(output_file_nonessential, 'w') as f:
                for pkg in sorted(nonessential_packages.keys()):
                    cats = ", ".join(sorted(list(nonessential_packages[pkg])))
                    f.write(f"{pkg} : {cats}\n")

        # Save the full list of all linux-firmware packages, categories, and their calculated sizes in build_dir/tmp/deploy/images/<dt>/all_firmware_packages.txt
        # It is used for debugging purposes only
        if all_packages_data:
            output_file_all = os.path.join(deploy_dir, "all_firmware_packages.txt")
            with open(output_file_all, 'w') as f:
                f.write(f"{'PACKAGE_NAME':<50} | {'SIZE (KiB)':>10} | {'CATEGORIES'}\n")
                f.write("-" * 80 + "\n")
                for pkg in sorted(all_packages_data.keys()):
                    cats = ", ".join(sorted(list(all_packages_data[pkg]["categories"])))
                    size_kb = all_packages_data[pkg]["size"] / 1024
                    f.write(f"{pkg:<50} | {size_kb:>10.2f} | {cats}\n")
            bb.note(f"\n[INFO] Saved full linux-firmware packages list with sizes to: {output_file_all}")

    # All files in packages should be succesfully mapped to a categorized driver
    if uncategorized_drivers:
        error_msg = "\n[ERROR] Uncategorized drivers found in build:\n"
        for drv, pkg in sorted(set(uncategorized_drivers)):
            error_msg += f"  - Driver: '{drv}' (Package: {pkg})\n"
        error_msg += "\nPlease check and update 'driver_categories' to include these."
        bb.fatal(error_msg)

python do_exclude_firmware() {
    import os
    import fnmatch
    # Use any file with the pattern *WHENCE, as we have an internal
    # one which contains additions to the upstream listing
    search_dirs = [d.getVar('D'), d.getVar('S'), d.getVar('WORKDIR')]
    found_whence = []
    for s_dir in search_dirs:
        if not s_dir: continue
        for root, dirs, files in os.walk(s_dir):
            for filename in fnmatch.filter(files, '*WHENCE'):
                found_whence.append(os.path.join(root, filename))

    final_paths = sorted(list(set(found_whence)))
    if not final_paths:
        bb.fatal("No files matching *WHENCE discovered in ${D}, ${S} or ${WORKDIR}")
        return

    bb.note("WHENCE FILES:")
    for path in final_paths:
        bb.note(f"Found: {path}")

    whence_map = parse_whences(d, final_paths)
    check_package_drivers(d, whence_map)
}

addtask exclude_firmware after do_unpack firmware_compression before do_package
