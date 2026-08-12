#
# Generates firmware_metadata.json: a unified structure mapping packages to
# categories/interfaces and firmware files to packages. Used for firmware
# exclusion policy and manifest verification.
#
# Output: DEPLOY_DIR_IMAGE/firmware_metadata.json
#
# JSON schema:
#   {
#     "version": 1,
#     "packages": { "pkg-name": { "category": "...", "interfaces": [...] } },
#     "firmware": { "canonical/path.ucode": "pkg-name" }
#   }
#

python () {
    # Inverted: driver -> category for O(1) lookup (do NOT use 'driver_categories'
    # - balena-firmware-exclusion uses that name with category->[drivers] format)
    global firmware_sort_driver_categories
    global firmware_sort_skip_list
    firmware_sort_driver_categories = {
    "amdgpu": "GPU", "isp": "GPU", "tegra-vic": "GPU", "nouveau": "GPU",
    "radeon": "GPU", "i915": "GPU", "xe": "GPU", "adreno": "GPU",
    "amdxdna": "GPU", "intel_vpu": "GPU", "amphion": "GPU", "powervr": "GPU",
    "panthor": "GPU",
    "snd-korg1212": "Audio", "snd-maestro3": "Audio", "snd-ymfpci": "Audio",
    "emi26": "Audio", "emi62": "Audio", "snd-sb16-csp": "Audio",
    "snd-wavefront": "Audio", "snd-hda-codec-ca0132": "Audio",
    "snd_soc_sst_acpi": "Audio", "snd_soc_catpt": "Audio", "snd_soc_avs": "Audio",
    "snd_intel_sst_core": "Audio", "snd-soc-skl": "Audio", "cs35l41": "Audio",
    "cs35l41_hda": "Audio", "cs35l56": "Audio", "cs42l43": "Audio", "cs42l45": "Audio",
    "mtk-sof": "Audio", "qcom-sc8280xp": "Audio", "qcom-qcs6490": "Audio",
    "qcom-qcs8300": "Audio", "qcom-qcs9100": "Audio", "qcom-sm8550": "Audio",
    "qcom-sm8650": "Audio", "qcom-x1e80100": "Audio", "ti-tas2781": "Audio",
    "ti-tas2563": "Audio", "qcm6490": "Audio", "qcs615": "Audio",
    "sm8450": "Audio", "sm8750": "Audio",
    "atomisp": "Video", "ipu3-imgu": "Video", "intel-ipu6-isys": "Video",
    "intel-ipu7-isys": "Video", "mei-vsc-hw": "Video", "dvb-ttusb-budget": "Video",
    "cpia2": "Video", "dabusb": "Video", "vicam": "Video", "cx231xx": "Video",
    "cx23418": "Video", "cx23885": "Video", "cx23840": "Video", "dvb-ttpci": "Video",
    "xc4000": "Video", "xc5000": "Video", "dib0700": "Video", "lgs8gxx": "Video",
    "ti-vpe": "Video", "tlg2300": "Video", "drxk": "Video", "s5p-mfc": "Video",
    "as102": "Video", "it9135": "Video", "smsmdtv": "Video", "mtk-vpu": "Video",
    "venus": "Video", "iris": "Video", "meson-vdec": "Video", "mt8196": "Video",
    "mga": "Video", "r128": "Video", "s2255drv": "Video", "go7007": "Video",
    "rk3399-dptx": "Video", "cdns-mhdp": "Video", "lt9611uxc": "Video",
    "wave5": "Video", "wave6": "Video", "ast": "Video",
    "sdx61": "Connectivity", "sdx35": "Connectivity", "ar9170": "Connectivity",
    "ath9k_htc": "Connectivity", "ath6kl": "Connectivity", "ar5523": "Connectivity",
    "carl9170": "Connectivity", "wil6210": "Connectivity", "ath10k": "Connectivity",
    "ath11k": "Connectivity", "ath12k": "Connectivity", "bnx2x": "Connectivity",
    "bnx2": "Connectivity", "brcmsmac": "Connectivity", "brcmfmac": "Connectivity",
    "cxgb3": "Connectivity", "cxgb4": "Connectivity", "mt7601u": "Connectivity",
    "mt76x0": "Connectivity", "mt76x2e": "Connectivity", "mt76x2u": "Connectivity",
    "mt7615e": "Connectivity", "mt7622": "Connectivity", "mt7663": "Connectivity",
    "mt7915e": "Connectivity", "mt7920": "Connectivity", "mt7921": "Connectivity",
    "mt7922": "Connectivity", "mt7925": "Connectivity", "mt7988": "Connectivity",
    "mtk-2p5ge": "Connectivity", "mt7996e": "Connectivity", "mtk_wed": "Connectivity",
    "mwifiex": "Connectivity", "orinoco": "Connectivity", "slicoss": "Connectivity",
    "sxg": "Connectivity", "e100": "Connectivity", "acenic": "Connectivity",
    "tg3": "Connectivity", "starfire": "Connectivity", "tehuti": "Connectivity",
    "typhoon": "Connectivity", "myri_sbus": "Connectivity", "netxen_nic": "Connectivity",
    "rt61pci": "Connectivity", "as21xxx": "Connectivity", "en8811h": "Connectivity",
    "an8811hb": "Connectivity", "airoha-npu-7581": "Connectivity",
    "airoha-npu-7583": "Connectivity", "vxge": "Connectivity", "myri10ge": "Connectivity",
    "cw1200": "Connectivity", "wilc1000": "Connectivity", "ice": "Connectivity",
    "nfp": "Connectivity", "mlxsw_spectrum": "Connectivity", "prestera": "Connectivity",
    "qla2xxx": "Connectivity", "ib_qib": "Connectivity", "qed": "Connectivity",
    "BFA/BNA": "Connectivity", "rt2800pci": "Connectivity", "rt2860sta": "Connectivity",
    "rt2800usb": "Connectivity", "rt2870sta": "Connectivity", "rtl8192e": "Connectivity",
    "r8712u": "Connectivity", "rtl8192ce": "Connectivity", "rtl8192cu": "Connectivity",
    "rtl8192se": "Connectivity", "rtl8192de": "Connectivity", "rtl8192du": "Connectivity",
    "rtl8723e": "Connectivity", "rtl8723be": "Connectivity", "rtl8723de": "Connectivity",
    "r8723au": "Connectivity", "rtl8188ee": "Connectivity", "rtl8188eu": "Connectivity",
    "rtl8821ae": "Connectivity", "rtl8822be": "Connectivity", "rtw88": "Connectivity",
    "rtw89": "Connectivity", "rtl8192ee": "Connectivity", "rtl8723bs": "Connectivity",
    "rtl8xxxu": "Connectivity", "r8169": "Connectivity", "r8152": "Connectivity",
    "rt1320": "Connectivity", "wl12xx": "Connectivity", "wl18xx": "Connectivity",
    "cc33xx": "Connectivity", "ueagle-atm": "Connectivity", "kaweth": "Connectivity",
    "rt73usb": "Connectivity", "vt6656": "Connectivity", "rsi": "Connectivity",
    "atusb": "Connectivity", "liquidio": "Connectivity", "iwlwifi": "Connectivity",
    "libertas": "Connectivity", "mwl8k": "Connectivity", "mwlwifi": "Connectivity",
    "wl1251": "Connectivity", "hfi1": "Connectivity", "qcom_q6v5_mss": "Connectivity",
    "ixp4xx-npe": "Connectivity", "pcnet_cs": "Connectivity", "3c589_cs": "Connectivity",
    "3c574_cs": "Connectivity", "smc91c92_cs": "Connectivity", "mscc-phy": "Connectivity",
    "wfx": "Connectivity",
    "ath3k": "Bluetooth", "DFU": "Bluetooth", "Atheros": "Bluetooth",
    "btusb": "Bluetooth", "qca": "Bluetooth", "btqca": "Bluetooth",
    "amlogic": "Bluetooth", "BCM-0bb4-0306": "Bluetooth", "btmtk_usb": "Bluetooth",
    "btmtk": "Bluetooth", "TI_ST": "Bluetooth", "btnxpuart": "Bluetooth",
    "isci": "Storage", "qla1280": "Storage", "qlogicpti": "Storage",
    "xhci-tegra": "Storage", "advansys": "Storage", "ene-ub6250": "Storage",
    "xhci-rcar": "Storage", "imx-sdma": "Storage", "microcode_amd": "Storage",
    "qat": "Misc", "ish": "Misc", "qcom_q6v5_pas": "Misc", "qaic": "Misc",
    "qdu100": "Misc", "qcom-geni-se": "Misc", "knav_qmss_queue": "Misc",
    "fsl-mc": "Misc", "dsp56k": "Misc", "cassini": "Misc", "yam": "Misc",
    "serial_cs": "Misc", "usbdux/usbduxfast/usbduxsigma": "Misc", "amd_pmf": "Misc",
    "ccp": "Misc", "nitrox": "Misc", "inside-secure": "Misc", "rvu_cptpf": "Misc",
    "nxp-sr1xx": "Misc", "Mont-TSSE": "Misc", "bmi260": "Misc",
    "pcie-rcar-gen4": "Misc", "keyspan": "Misc", "keyspan_pda": "Misc",
    "ti_usb_3410_5052": "Misc", "whiteheat": "Misc", "io_edgeport": "Misc",
    "io_ti": "Misc", "rp2": "Misc", "mxu11x0": "Misc", "mxuport": "Misc",
    "mtk_scp": "Misc",
    }

    firmware_sort_skip_list = [
    "linux-firmware-license", "linux-firmware-dev", "linux-firmware-doc",
    "linux-firmware-locale", "linux-firmware", "linux-firmware-dbg",
    "linux-firmware-staticdev"
    ]
}

def parse_whences(d, whence_paths):
    """Parse linux-firmware WHENCE files. Extracts Driver: sections and their
    File:/RawFile:/Link: entries.

    Example WHENCE input:
        Driver: iwlwifi
        File: iwlwifi-3160-12.ucode
        File: iwlwifi-6000g2a-5.ucode

    Returns e.g. {"iwlwifi": ["iwlwifi-3160-12.ucode", "iwlwifi-6000g2a-5.ucode"], ...}"""
    import re
    whence_map = {}
    for path in whence_paths:
        with open(path, 'r') as f:
            current_driver = None
            for line in f:
                line = line.strip()
                if not line or line.startswith("Licence:"):
                    continue
                if line.startswith("Driver:"):
                    match = re.search(r'Driver:\s*([^\s]+)', line)
                    current_driver = match.group(1).rstrip(':').strip() if match else None
                    if current_driver and current_driver not in whence_map:
                        whence_map[current_driver] = []
                elif current_driver:
                    if line.startswith("File:") or line.startswith("RawFile:"):
                        whence_map[current_driver].append(line.split(':', 1)[1].strip())
                    elif line.startswith("Link:"):
                        for lf in [p.strip() for p in line.split(':', 1)[1].split('->')]:
                            if lf not in whence_map[current_driver]:
                                whence_map[current_driver].append(lf)
    return whence_map

def canonical_firmware_path(path):
    COMPRESSION_SUFFIXES = ('.xz', '.gz', '.zst')
    for ext in COMPRESSION_SUFFIXES:
        if path.endswith(ext):
            return path[:-len(ext)]
    return path

def find_driver_for_file(canonical_path, known_files):
    import fnmatch
    for fw_file, driver in known_files:
        if (fnmatch.fnmatch(fw_file, canonical_path) or fnmatch.fnmatch(canonical_path, fw_file) or
                canonical_path in fw_file or fw_file in canonical_path):
            return driver
    return None

def find_whence_files(d):
    import os
    import fnmatch
    search_dirs = [d.getVar('D'), d.getVar('S'), d.getVar('WORKDIR')]
    found = []
    for s_dir in search_dirs:
        if not s_dir:
            continue
        for root, dirs, files in os.walk(s_dir):
            for f in fnmatch.filter(files, '*WHENCE'):
                found.append(os.path.join(root, f))
    return sorted(set(found))

def get_package_interfaces(pkg, fw_feature_map):
    interfaces = []
    for feat, pkg_list in fw_feature_map.items():
        if pkg in pkg_list.split():
            interfaces.append(feat)
    return sorted(interfaces)

def _pattern_under_fw_root(pattern, root):
    pat_norm = pattern.lstrip('/')
    root_norm = root.lstrip('/')
    return pat_norm.startswith(root_norm) or pattern.startswith(root)

def _expand_firmware_pattern(pattern, image_dir, nonarch):
    """Resolve a FILES glob (e.g. lib/firmware/iwlwifi/*) to the actual files on disk.
    Lists the target directory, matches filenames against the glob, returns canonical paths
    (relative to firmware root, compression suffixes stripped)."""
    import os
    import fnmatch
    firmware_root_prefix = os.path.join(nonarch, 'firmware').lstrip('/')
    firmware_root_absolute = os.path.normpath(os.path.join(image_dir, firmware_root_prefix))
    possible_roots = [firmware_root_prefix, '/usr/lib/firmware', '/lib/firmware', 'lib/firmware']
    pattern_normalized = pattern.lstrip('/')
    for root in possible_roots:
        if not _pattern_under_fw_root(pattern, root):
            continue
        full_pattern = os.path.join(image_dir, pattern_normalized)
        directory = os.path.dirname(full_pattern)
        file_pattern = os.path.basename(full_pattern)
        if not os.path.exists(directory):
            break
        canonical_paths = []
        for filename in os.listdir(directory):
            if fnmatch.fnmatch(filename, file_pattern):
                filepath = os.path.join(directory, filename)
                if os.path.isfile(filepath) and not os.path.islink(filepath):
                    relative_path = os.path.relpath(filepath, firmware_root_absolute)
                    canonical_paths.append(canonical_firmware_path(relative_path))
        return canonical_paths
    return []

def process_package_files(pkg, pkg_files_var, image_dir, nonarch, known_files):
    """Resolve each FILES glob to actual firmware files, map each to its driver via WHENCE.
    Fails on first firmware file not in WHENCE. Returns (pkg_drivers, firmware_entries)."""
    pkg_drivers = set()
    firmware_entries = {}
    for pattern in pkg_files_var.split():
        for canonical_path in _expand_firmware_pattern(pattern, image_dir, nonarch):
            driver = find_driver_for_file(canonical_path, known_files)
            if driver is None:
                bb.fatal(f"Firmware file not in WHENCE: {canonical_path} (package: {pkg})")
            pkg_drivers.add(driver)
            firmware_entries[canonical_path] = pkg
    return pkg_drivers, firmware_entries

def resolve_category(pkg_drivers, driver_categories, pkg):
    """Resolve package category from its drivers. Fails on first uncategorized driver."""
    pkg_categories = set()
    for drv in pkg_drivers:
        cat = driver_categories.get(drv, "Unknown")
        if cat == "Unknown":
            bb.fatal(f"Uncategorized driver: {drv} (package: {pkg})")
        pkg_categories.add(cat)
    if "Connectivity" in pkg_categories:
        return "Connectivity"
    if "Storage" in pkg_categories:
        return "Storage"
    if pkg_categories:
        return sorted(pkg_categories)[0]
    return "Unknown"

def write_firmware_metadata(deploy_dir, packages, firmware):
    import os
    import json
    if not deploy_dir:
        return
    bb.utils.mkdirhier(deploy_dir)
    out = os.path.join(deploy_dir, "firmware_metadata.json")
    with open(out, 'w') as f:
        json.dump({
            "version": 1,
            "packages": packages,
            "firmware": firmware
        }, f, indent=2, sort_keys=True)
    bb.note(f"Wrote firmware_metadata.json to {out}")

python do_firmware_sort() {
    global firmware_sort_driver_categories
    global firmware_sort_skip_list

    whence_paths = find_whence_files(d)
    if not whence_paths:
        bb.fatal("No *WHENCE files found in ${D}, ${S} or ${WORKDIR}")

    whence_map = parse_whences(d, whence_paths)
    known_files = [(f, drv) for drv, files in whence_map.items() for f in files]

    image_dir = d.getVar('D')
    nonarch = d.getVar('nonarch_base_libdir') or 'lib'
    packages_var = (d.getVar('PACKAGES') or "").split()
    fw_feature_map = d.getVarFlags('LINUX_FIRMWARE_PACKAGES') or {}

    packages = {}
    firmware = {}

    for pkg in packages_var:
        if pkg in firmware_sort_skip_list or "license" in pkg:
            continue
        pkg_files_var = d.getVar(f'FILES:{pkg}')
        if not pkg_files_var:
            continue

        pkg_drivers, fw_entries = process_package_files(
            pkg, pkg_files_var, image_dir, nonarch, known_files)
        firmware.update(fw_entries)

        if not pkg_drivers:
            continue

        category = resolve_category(pkg_drivers, firmware_sort_driver_categories, pkg)
        pkg_interfaces = get_package_interfaces(pkg, fw_feature_map)
        packages[pkg] = {"category": category, "interfaces": pkg_interfaces}

    write_firmware_metadata(d.getVar('DEPLOY_DIR_IMAGE'), packages, firmware)
}

addtask firmware_sort after do_unpack firmware_compression before do_package
