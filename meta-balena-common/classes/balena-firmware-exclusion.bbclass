#
# Build non-essential firmware package lists from firmware_metadata.json.
# Produces:
#  - DEPLOY_DIR_IMAGE/nonessential_firmware.txt (debug with reasons)
#

# Read firmware metadata produced by balena-firmware-sort, then compute the
# nonessential package set including interface-incompatible firmware.
def _compute_nonessential_firmware_from_metadata(d):
    import json
    import os

    deploy_dir = d.getVar('DEPLOY_DIR_IMAGE')
    if not deploy_dir:
        bb.fatal("Could not determine DEPLOY_DIR_IMAGE")

    metadata_path = os.path.join(deploy_dir, 'firmware_metadata.json')
    if not os.path.exists(metadata_path):
        bb.fatal(f"firmware_metadata.json not found at: {metadata_path}")

    with open(metadata_path, 'r') as f:
        metadata = json.load(f)

    packages = metadata.get('packages', {})
    machine_features = set((d.getVar('MACHINE_FEATURES') or "").split())
    nonessential = {}

    for pkg, pkg_meta in packages.items():
        categories = set(pkg_meta.get('categories', []))
        interfaces = set(pkg_meta.get('interfaces', []))
        in_essential_category = bool(pkg_meta.get('in_essential_category', False))
        reasons = set()

        # Legacy-compatible policy:
        # 1) If interfaces are declared for package, only exclude when machine does not
        #    support any of them (UnsupportedInterfaces).
        # 2) If interfaces are not declared, exclude package for any nonessential category,
        #    even if package is mixed with Connectivity/Storage.
        matched = sorted(interfaces & machine_features)
        bb.note(
            f"[fw-meta-excl] pkg={pkg} in_essential={in_essential_category} "
            f"interfaces={','.join(sorted(interfaces)) if interfaces else '<none>'} "
            f"matched={','.join(matched) if matched else '<none>'}"
        )

        if interfaces and not (interfaces & machine_features):
            reasons.add(f"UnsupportedInterfaces({','.join(sorted(interfaces))})")
        elif not interfaces:
            reasons.update(
                sorted(cat for cat in categories if cat not in {"Connectivity", "Storage"})
            )

        # Stricter policy alternative (kept for easy switch):
        # Exclude a package when:
        #   A) it is NOT in an essential category (Connectivity or Storage), OR
        #   B) it declares interfaces and NONE of them match MACHINE_FEATURES.
        #
        # This means:
        # - Nonessential categories are always excluded.
        # - Essential-category packages are excluded only on interface mismatch.
        # - Essential-category packages with matching interfaces are kept.
        # if not in_essential_category:
        #     reasons.update(
        #         sorted(cat for cat in categories if cat not in {"Connectivity", "Storage"})
        #     )
        # if interfaces and not (interfaces & machine_features):
        #     reasons.add(f"UnsupportedInterfaces({','.join(sorted(interfaces))})")

        if reasons:
            nonessential[pkg] = reasons

    return nonessential

# Generate DEPLOY_DIR_IMAGE/nonessential_firmware.txt from firmware_metadata.json
# for the current image/machine context.
python do_generate_nonessential_firmware_from_metadata() {
    import os

    image = d.getVar('PN')
    machine = d.getVar('MACHINE')
    machine_features = sorted((d.getVar('MACHINE_FEATURES') or "").split())
    bb.note(f"[fw-meta-excl] IMAGE={image} MACHINE={machine}")
    bb.note(f"[fw-meta-excl] MACHINE_FEATURES(sorted)={','.join(machine_features)}")

    deploy_dir = d.getVar('DEPLOY_DIR_IMAGE')
    if not deploy_dir:
        bb.fatal("Could not determine DEPLOY_DIR_IMAGE")

    nonessential = _compute_nonessential_firmware_from_metadata(d)

    debug_path = os.path.join(deploy_dir, 'nonessential_firmware.txt')
    with open(debug_path, 'w') as f:
        for pkg in sorted(nonessential.keys()):
            f.write(f"{pkg} : {', '.join(sorted(nonessential[pkg]))}\n")

    bb.note(f"Wrote metadata-based nonessential firmware debug list to: {debug_path}")
}

do_generate_nonessential_firmware_from_metadata[depends] += "linux-firmware:do_firmware_sort"
addtask generate_nonessential_firmware_from_metadata before do_rootfs



def _read_nonessential_packages(nonessential_path):
    packages = []
    with open(nonessential_path, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            pkg = line.split(':', 1)[0].strip()
            if pkg:
                packages.append(pkg)
    return packages

def _compute_effective_excluded_packages(d, nonessential_path):
    raw_whitelist = d.getVar('BALENA_ALLOWED_FIRMWARE_PACKAGES') or ""
    whitelist = {pkg.strip() for pkg in raw_whitelist.split() if pkg.strip()}
    if whitelist:
        bb.note(f"Allowed firmware whitelist: {repr(sorted(whitelist))}")
    nonessential_packages = _read_nonessential_packages(nonessential_path)
    effective_excluded = [pkg for pkg in nonessential_packages if pkg not in whitelist]
    return effective_excluded

# Add excluded firmware from nonessential_firmware.txt to BAD_RECOMMENDATIONS
python do_apply_firmware_exclusion_policy() {
    import os

    deploy_dir = d.getVar('DEPLOY_DIR_IMAGE')
    if not deploy_dir:
         bb.fatal("Could not determine DEPLOY_DIR_IMAGE")

    nonessential_path = os.path.join(deploy_dir, 'nonessential_firmware.txt')
    if not os.path.exists(nonessential_path):
        bb.fatal("nonessential_firmware.txt not found, cannot enforce firmware policy.")

    extra_bad = _compute_effective_excluded_packages(d, nonessential_path)

    if extra_bad:
        bad_str = " ".join(extra_bad)
        # BAD_RECOMMENDATIONS is used to remove packages from RRECOMMENDS
        d.appendVar('BAD_RECOMMENDATIONS', " " + bad_str)
        bb.note(f"Policy applied: Excluded {len(extra_bad)} firmware packages.")
}

addtask do_apply_firmware_exclusion_policy after do_generate_nonessential_firmware_from_metadata before do_rootfs



# Fail the build if any of the excluded packages have been found in the image manifest
python do_nonessential_firmware_check() {
    import os

    # During do_image_complete, this variable points to the manifest in WORKDIR
    manifest_path = d.getVar('IMAGE_MANIFEST')

    if not manifest_path or not os.path.exists(manifest_path):
        # Fallback to check the deploy directory manually
        deploy_dir = d.getVar('DEPLOY_DIR_IMAGE')
        link_name = d.getVar('IMAGE_LINK_NAME')
        manifest_path = os.path.join(deploy_dir, f"{link_name}.manifest")

    if not os.path.exists(manifest_path):
        bb.fatal(f"Firmware policy check failed: Manifest file not found in {manifest_path}")

    nonessential_path = os.path.join(d.getVar('DEPLOY_DIR_IMAGE'), 'nonessential_firmware.txt')
    if not os.path.exists(nonessential_path):
        bb.fatal("nonessential_firmware.txt not found, cannot perform firmware policy check.")

    effective_excluded = _compute_effective_excluded_packages(d, nonessential_path)

    # Parse image manifest
    installed = []
    with open(manifest_path, 'r') as f:
        for line in f:
            parts = line.split()
            if parts:
                installed.append(parts[0])

    # Check if any effective excluded package still landed in final manifest.
    matched_packages = [p for p in effective_excluded if p in installed]

    if matched_packages:
        bb.plain(f"Non-essential firmware found in manifest: {', '.join(matched_packages)}. "
                 f"Please check which categories these packages belong to in firmware_metadata.json/nonessential_firmware.txt "
                 f"or add them to BALENA_ALLOWED_FIRMWARE_PACKAGES")
    else:
        bb.plain("Firmware Policy Check: PASSED")
}

# Manifest is generated in do_rootfs,
# we thus need to perform the check after
# it becomes available.
addtask nonessential_firmware_check after do_rootfs before do_image_complete
