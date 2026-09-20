#
# Generates firmware_metadata.json from packages-split and WHENCE:
#   1) collect file -> package from packages-split
#   2) collect file -> category from WHENCE and driver category map
#   3) aggregate package categories and interfaces
#
# Output:
#   DEPLOY_DIR_IMAGE/firmware_metadata.json
#
# JSON schema:
#   {
#     "linux-firmware-ar5523": {
#       "categories": ["Connectivity"],
#       "in_essential_category": true,
#       "interfaces": []
#     }
#   }
#

inherit balena-firmware-sort-data
inherit balena-firmware-symlink-debugging
inherit deploy

def find_whence_files(d):
    import os
    import fnmatch
    # Scan install/source/work dirs so we pick both upstream WHENCE and any
    # extra WHENCE files injected from layers/recipes.
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

def is_in_essential_category(pkg_categories):
    essential_categories = {"Connectivity", "Storage"}
    return bool(set(pkg_categories) & essential_categories)

def canonical_firmware_path(path):
    # Normalize compressed/uncompressed variants to one logical firmware path.
    COMPRESSION_SUFFIXES = ('.xz', '.gz', '.zst')
    for ext in COMPRESSION_SUFFIXES:
        if path.endswith(ext):
            return path[:-len(ext)]
    return path

def _collect_split_package_files(pkg, packages_split_dir, usrlib_prefix):
    import os

    pkg_root = os.path.join(packages_split_dir, pkg)
    firmware_root = os.path.join(pkg_root, (usrlib_prefix or '/usr/lib').lstrip('/'), 'firmware')
    if not os.path.isdir(firmware_root):
        return []

    files = []
    for walk_root, _, filenames in os.walk(firmware_root):
        for filename in filenames:
            filepath = os.path.join(walk_root, filename)
            if os.path.isfile(filepath):
                relpath = os.path.relpath(filepath, firmware_root)
                files.append(canonical_firmware_path(relpath))
    return sorted(set(files))

def _build_file_to_package_map(packages_var, packages_split_dir, usrlib_prefix, skip_list):
    # This function looks into packages-split and list all firmwares present in the package.
    # It returns a dict of "firmware_path": "package-name".
    # If two packages expose the same canonical firmware path, we fail instead
    # of silently letting the later package overwrite the earlier ownership.
    file_to_package = {}
    for pkg in packages_var:
        if pkg in skip_list or "license" in pkg:
            continue

        for canonical_path in _collect_split_package_files(pkg, packages_split_dir, usrlib_prefix):
            owner = file_to_package.get(canonical_path)
            if owner and owner != pkg:
                bb.fatal(
                    f"Firmware file assigned to multiple packages in packages-split: "
                    f"{canonical_path} ({owner}, {pkg})"
                )
            file_to_package[canonical_path] = pkg
    return file_to_package

def _build_file_to_category_map_from_whences(d, whence_paths, driver_categories):
    # Parse WHENCE files and map firmware path -> category.
    import re

    def normalize_whence_path(token):
        # WHENCE may encode paths with quotes and/or escaped spaces.
        token = token.strip()
        if len(token) >= 2 and token[0] == '"' and token[-1] == '"':
            token = token[1:-1]
        return token.replace('\\ ', ' ')

    def parse_driver_from_line(line):
        match = re.search(r'Driver:\s*([^\s]+)', line)
        return match.group(1).rstrip(':').strip() if match else None

    def parse_whence_payload_paths(line):
        if line.startswith("File:") or line.startswith("RawFile:"):
            return [normalize_whence_path(line.split(':', 1)[1])]
        if line.startswith("Link:"):
            # WHENCE Link syntax is "alias -> target"; keep both paths.
            return [normalize_whence_path(p) for p in line.split(':', 1)[1].split('->')]
        return []

    # If a firmware file gets multiple categories, fail.
    # This can happen if the same path appears under multiple WHENCE drivers,
    # or when a WHENCE Link alias/target collides with another categorized path.
    def add_whence_path_category(file_to_category, path, category):
        canonical_path = canonical_firmware_path(path)
        existing_category = file_to_category.get(canonical_path)
        if existing_category and existing_category != category:
            bb.fatal(
                f"Firmware file mapped to multiple categories: "
                f"{canonical_path} ({existing_category}, {category})"
            )
        file_to_category[canonical_path] = category

    file_to_category = {}
    for path in whence_paths:
        with open(path, 'r') as f:
            current_category = None
            for raw_line in f:
                line = raw_line.strip()
                if not line or line.startswith("Licence:"):
                    continue

                if line.startswith("Driver:"):
                    driver = parse_driver_from_line(line)
                    current_category = driver_categories.get(driver) if driver else None
                    if driver and current_category is None:
                        bb.fatal(f"Uncategorized driver in WHENCE: {driver}")
                    continue

                if current_category is None:
                    continue

                # File/RawFile lines contribute one firmware file path.
                # Link lines (WHENCE symlinks) contribute both the symlink alias
                # path and its target path, so both resolve to the same category.
                for fw_path in parse_whence_payload_paths(line):
                    add_whence_path_category(file_to_category, fw_path, current_category)

    return file_to_category

def _is_debug_balena_firmware_enabled(d):
    # Keep debug output tied to development builds only.
    return (d.getVar('OS_DEVELOPMENT') or "").strip() == "1"

# debug outputs: symlink ownership diagnostics and
# file->package / file->category JSON maps.
def _show_debug(d, packages_var, packages_split_dir, usrlib_prefix, skip_list, file_to_package, file_to_category):
    import json
    import os

    if not _is_debug_balena_firmware_enabled(d):
        return

    deploy_dir = d.getVar('DEPLOY_DIR_IMAGE')
    if not deploy_dir:
        bb.fatal("Could not determine DEPLOY_DIR_IMAGE")
    bb.utils.mkdirhier(deploy_dir)

    # This will resolve the different symlink, and verify that they point to file inside the package.
    # Otherwise it will emit a warning and verify the dependencies.
    _debug_report_suspicious_package_symlinks(
        d, packages_var, packages_split_dir, usrlib_prefix, skip_list, file_to_package
    )

    file_to_package_path = os.path.join(deploy_dir, "firmware_file_to_package.json")
    with open(file_to_package_path, "w") as f:
        json.dump(file_to_package, f, indent=2, sort_keys=True)

    file_to_category_path = os.path.join(deploy_dir, "firmware_file_to_category.json")
    with open(file_to_category_path, "w") as f:
        json.dump(file_to_category, f, indent=2, sort_keys=True)

    bb.note(f"Wrote file->package map to: {file_to_package_path}")
    bb.note(f"Wrote file->category map to: {file_to_category_path}")

def get_firmware_metadata_work_path(d):
    import os

    workdir = d.getVar('WORKDIR')
    if not workdir:
        bb.fatal("Could not determine WORKDIR")
    return os.path.join(workdir, "firmware_metadata.json")

def save_package_metadata(d, packages_metadata):
    import json

    output_path = get_firmware_metadata_work_path(d)
    with open(output_path, "w") as f:
        json.dump(packages_metadata, f, indent=2, sort_keys=True)

    bb.note(f"Wrote firmware metadata work file to: {output_path}")

def _fail_missing_whence_entries(missing_in_whence):
    if not missing_in_whence:
        return

    missing_lines = "\n".join(
        f"  - {path} (package: {pkg})" for path, pkg in missing_in_whence
    )
    bb.fatal(
        "Firmware files not in WHENCE:\n"
        f"{missing_lines}\n"
        "Please add them to WHENCE/extra_WHENCE with a known Driver category."
    )

# do_firmware_sort is the entry point for the sorting mechanism
# 1) collect canonical firmware file ownership from packages-split (file -> package)
# 2) parse WHENCE and resolve canonical file categories with firmware_sort_driver_categories (file -> category) 
# 3) combine file->package and file->category to derive package categories
#    (plus interfaces), then write firmware_metadata.json
python do_firmware_sort() {
    import json
    import os

    global firmware_sort_driver_categories
    global firmware_sort_skip_list

    whence_paths = find_whence_files(d)
    if not whence_paths:
        bb.fatal("No *WHENCE files found in ${D}, ${S} or ${WORKDIR}")

    packages_split_dir = d.getVar('PKGDEST') or os.path.join(d.getVar('WORKDIR'), 'packages-split')
    if not os.path.isdir(packages_split_dir):
        bb.fatal(f"packages-split directory not found: {packages_split_dir}")

    usrlib_prefix = d.getVar('nonarch_base_libdir') or 'lib'
    packages_var = (d.getVar('PACKAGES') or "").split()
    # LINUX_FIRMWARE_PACKAGES flags map interface/feature -> package list
    # (e.g. "pci" -> "linux-firmware-iwlwifi-3160 ...").
    # We use this to populate the per-package "interfaces" metadata.
    fw_feature_map = d.getVarFlags('LINUX_FIRMWARE_PACKAGES') or {}

    # Here we list all files present in Yocto linux-firmware packages.
    file_to_package = _build_file_to_package_map(
        packages_var, packages_split_dir, usrlib_prefix, firmware_sort_skip_list
    )
    # Here we list all the files present in WHENCE and map them with a category
    file_to_category = _build_file_to_category_map_from_whences(
        d, whence_paths, firmware_sort_driver_categories
    )

    _show_debug(
        d,
        packages_var,
        packages_split_dir,
        usrlib_prefix,
        firmware_sort_skip_list,
        file_to_package,
        file_to_category,
    )

    packages_metadata = {}
    package_categories = {}

    # for each canonical firmware file owned by a package, we look up its
    # category from WHENCE and build package -> set(categories).
    # If a file exists in packages-split but has no WHENCE category, we fail
    # so that all firmware has to be categorized.
    missing_in_whence = []
    for canonical_path, pkg in sorted(file_to_package.items()):
        category = file_to_category.get(canonical_path)
        if category is None:
            missing_in_whence.append((canonical_path, pkg))
            continue

        package_categories.setdefault(pkg, set()).add(category)

    if missing_in_whence:
        _fail_missing_whence_entries(missing_in_whence)

    for pkg in sorted(package_categories.keys()):
        categories = sorted(package_categories[pkg])
        packages_metadata[pkg] = {
            "categories": categories,
            "in_essential_category": is_in_essential_category(categories),
            "interfaces": get_package_interfaces(pkg, fw_feature_map),
        }

    save_package_metadata(d, packages_metadata)
}

do_deploy() {
    install -d ${DEPLOYDIR}
    install -m 0644 ${WORKDIR}/firmware_metadata.json ${DEPLOYDIR}/firmware_metadata.json
}

addtask firmware_sort after do_package before do_packagedata
addtask deploy after do_firmware_sort before do_packagedata
do_firmware_sort[depends] += "${PN}:do_unpack"