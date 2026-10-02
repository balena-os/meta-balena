#
# Build non-essential firmware package lists from firmware_metadata.json.
# Produces:
#  - DEPLOY_DIR_IMAGE/nonessential_firmware.txt (debug with reasons)
#

BALENA_FIRMWARE_EXCLUSION_ENABLED ?= "1"

def _is_firmware_exclusion_enabled(d):
    value = (d.getVar('BALENA_FIRMWARE_EXCLUSION_ENABLED') or "").strip()
    return value == "1"

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

    packages = {}
    with open(metadata_path, 'r') as f:
        packages = json.load(f)

    machine_features = set((d.getVar('MACHINE_FEATURES') or "").split())
    nonessential = {}

    for pkg, pkg_meta in packages.items():
        categories = set(pkg_meta.get('categories', []))
        interfaces = set(pkg_meta.get('interfaces', []))
        in_essential_category = bool(pkg_meta.get('in_essential_category', False))
        reasons = set()

        # Exclude a package when:
        #   A) it is NOT in an essential category (Connectivity or Storage), OR
        #   B) it declares interfaces and NONE of them match MACHINE_FEATURES.
        #
        # This means:
        # - Nonessential categories are always excluded.
        # - Essential-category packages are excluded only on interface mismatch.
        # - Essential-category packages with matching interfaces are kept.
        if not in_essential_category:
            reasons.update(
                sorted(cat for cat in categories if cat not in {"Connectivity", "Storage"})
            )
        if interfaces and not (interfaces & machine_features):
            reasons.add(f"UnsupportedInterfaces({','.join(sorted(interfaces))})")

        if reasons:
            nonessential[pkg] = reasons

    return nonessential

def _get_allowed_firmware_whitelist(d):
    raw_whitelist = d.getVar('BALENA_ALLOWED_FIRMWARE_PACKAGES') or ""
    return {pkg.strip() for pkg in raw_whitelist.split() if pkg.strip()}

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
    whitelist = _get_allowed_firmware_whitelist(d)
    if whitelist:
        bb.note(f"Allowed firmware whitelist: {repr(sorted(whitelist))}")

    debug_path = os.path.join(deploy_dir, 'nonessential_firmware.txt')
    with open(debug_path, 'w') as f:
        for pkg in sorted(nonessential.keys()):
            line = f"{pkg} : {', '.join(sorted(nonessential[pkg]))}"
            # Keep raw policy visibility while making whitelist effect explicit.
            if pkg in whitelist:
                f.write(f"# {line}  # whitelisted\n")
            else:
                f.write(f"{line}\n")

    bb.note(f"Wrote metadata-based nonessential firmware debug list to: {debug_path}")
}

do_generate_nonessential_firmware_from_metadata[depends] += "linux-firmware:do_deploy"
addtask generate_nonessential_firmware_from_metadata before do_rootfs



def _get_nonessential_firmware_packages(d):
    nonessential_path = get_nonessential_firmware_path(d)
    packages = []
    with open(nonessential_path, 'r') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            pkg = line.split(':', 1)[0].strip()
            if pkg:
                packages.append(pkg)
    return packages

def get_nonessential_firmware_path(d):
    import os

    deploy_dir = d.getVar('DEPLOY_DIR_IMAGE')
    if not deploy_dir:
         bb.fatal("Could not determine DEPLOY_DIR_IMAGE")

    nonessential_path = os.path.join(deploy_dir, 'nonessential_firmware.txt')
    if not os.path.exists(nonessential_path):
        bb.fatal("nonessential_firmware.txt not found.")

    return nonessential_path

# Add excluded firmware from nonessential_firmware.txt to BAD_RECOMMENDATIONS
python do_apply_firmware_exclusion_policy() {
    if not _is_firmware_exclusion_enabled(d):
        bb.note("Firmware exclusion is disabled; skipping BAD_RECOMMENDATIONS updates")
        return

    extra_bad = _get_nonessential_firmware_packages(d)

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

    if not _is_firmware_exclusion_enabled(d):
        bb.note("Firmware exclusion is disabled; skipping manifest enforcement")
        return

    # During do_image_complete, this variable points to the manifest in WORKDIR
    manifest_path = d.getVar('IMAGE_MANIFEST')

    if not manifest_path or not os.path.exists(manifest_path):
        # Fallback to check the deploy directory manually
        deploy_dir = d.getVar('DEPLOY_DIR_IMAGE')
        link_name = d.getVar('IMAGE_LINK_NAME')
        manifest_path = os.path.join(deploy_dir, f"{link_name}.manifest")

    if not os.path.exists(manifest_path):
        bb.fatal(f"Firmware policy check failed: Manifest file not found in {manifest_path}")

    effective_excluded = _get_nonessential_firmware_packages(d)

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
        bb.fatal(f"Non-essential firmware found in manifest: {', '.join(matched_packages)}. "
                 f"Please check which categories these packages belong to in firmware_metadata.json/nonessential_firmware.txt "
                 f"or add them to BALENA_ALLOWED_FIRMWARE_PACKAGES")
    else:
        bb.plain("Firmware Policy Check: PASSED")
}

# Manifest is generated in do_rootfs,
# we thus need to perform the check after
# it becomes available.
addtask nonessential_firmware_check after do_rootfs before do_image_complete
