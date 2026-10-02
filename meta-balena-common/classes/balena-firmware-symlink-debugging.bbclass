#
# Debug helpers to detect suspicious firmware symlinks in packages-split.
#
# About the /!\/!\ warning:
#   /!\/!\ [fw-sort] missing runtime dependency: package=<A>
#   link=<alias> candidate_without_dep=<B> /!\/!\
#
# This means package <A> ships a firmware symlink whose canonical target looks
# owned by package <B> in packages-split, but <A> does not explicitly declare
# RDEPENDS/RRECOMMENDS on <B>. This is informational and helps spot cross-package
# symlink ownership/dependency mismatches.
#
# Known findings currently observed:
#   - linux-firmware-nvidia-tegra -> linux-firmware-nvidia-gpu
#   - linux-firmware-qcom-qcm2290-wifi -> linux-firmware-ath10k
#   - linux-firmware-qcom-qrb4210-wifi -> linux-firmware-ath10k
#   - linux-firmware-qcom-sdm845-modem -> linux-firmware-ath10k
#
# These are deemed safe for now: we keep them as warnings
# and we only use them to document/package ownership caveats.
#

def _symlink_debug_canonical_firmware_path(path):
    compression_suffixes = ('.xz', '.gz', '.zst')
    for ext in compression_suffixes:
        if path.endswith(ext):
            return path[:-len(ext)]
    return path

def _find_suspicious_package_firmware_symlinks(pkg, packages_split_dir, usrlib_prefix):
    import os

    pkg_root = os.path.join(packages_split_dir, pkg)
    firmware_root = os.path.join(pkg_root, (usrlib_prefix or '/usr/lib').lstrip('/'), 'firmware')
    if not os.path.isdir(firmware_root):
        return []

    firmware_root_abs = os.path.abspath(firmware_root)
    suspicious = []

    for walk_root, _, filenames in os.walk(firmware_root):
        for filename in filenames:
            link_path = os.path.join(walk_root, filename)
            if not os.path.islink(link_path):
                continue

            link_target = os.readlink(link_path)
            target_abs = os.path.abspath(os.path.join(os.path.dirname(link_path), link_target))

            target_inside_firmware_root = (
                os.path.commonpath([firmware_root_abs, target_abs]) == firmware_root_abs
            )
            if not target_inside_firmware_root:
                reason = "target_outside_package_firmware_root"
            elif not os.path.lexists(target_abs):
                reason = "target_missing_in_package_firmware_root"
            else:
                reason = None

            if reason:
                rel_link = os.path.relpath(link_path, firmware_root)
                rel_target = os.path.normpath(
                    os.path.join(os.path.dirname(rel_link), link_target)
                ).replace('\\', '/')
                suspicious.append(
                    {
                        "reason": reason,
                        "link": _symlink_debug_canonical_firmware_path(rel_link),
                        "target": link_target,
                        "target_abs": target_abs,
                        "target_canonical": _symlink_debug_canonical_firmware_path(rel_target),
                    }
                )

    return sorted(suspicious, key=lambda item: item["link"])

def _invert_file_to_package_map(file_to_package):
    target_to_packages = {}
    for firmware_path, pkg in file_to_package.items():
        target_to_packages.setdefault(firmware_path, set()).add(pkg)
    return target_to_packages

def _get_runtime_deps_for_package(d, pkg):
    deps = set()
    for varname in [f"RDEPENDS:{pkg}", f"RRECOMMENDS:{pkg}"]:
        value = d.getVar(varname) or ""
        if value:
            deps.update(value.split())
    return deps

def _debug_report_suspicious_package_symlinks(d, packages_var, packages_split_dir, usrlib_prefix, skip_list, file_to_package):
    total = 0
    target_to_packages = _invert_file_to_package_map(file_to_package)
    for pkg in packages_var:
        if pkg in skip_list or "license" in pkg:
            continue

        suspicious = _find_suspicious_package_firmware_symlinks(pkg, packages_split_dir, usrlib_prefix)
        if not suspicious:
            continue

        total += len(suspicious)
        bb.warn(
            f"[fw-sort] package {pkg} has {len(suspicious)} firmware symlink(s) "
            "with suspicious target ownership"
        )
        for item in suspicious:
            candidate_pkgs = sorted(target_to_packages.get(item["target_canonical"], []))
            dep_candidates = []
            runtime_deps = _get_runtime_deps_for_package(d, pkg)
            missing_dep_candidates = []
            for candidate in candidate_pkgs:
                if candidate not in runtime_deps:
                    missing_dep_candidates.append(candidate)
                dep_candidates.append(f"{candidate}:{'yes' if candidate in runtime_deps else 'no'}")
            candidate_hint = (
                f" candidates_in_packages_split={','.join(candidate_pkgs)}"
                if candidate_pkgs else
                " candidates_in_packages_split=<none>"
            )
            depends_hint = (
                f" depends_declared={','.join(dep_candidates)}"
                if dep_candidates else
                " depends_declared=<none>"
            )
            bb.warn(
                f"[fw-sort]   reason={item['reason']} "
                f"link={item['link']} -> {item['target']} "
                f"(resolved={item['target_abs']})"
                f"{candidate_hint}"
                f"{depends_hint}"
            )
            if candidate_pkgs and missing_dep_candidates:
                bb.warn(
                    f"/!\\/!\\ [fw-sort] missing runtime dependency: "
                    f"package={pkg} link={item['link']} "
                    f"candidate_without_dep={','.join(missing_dep_candidates)} /!\\/!\\"
                )

    if total:
        bb.warn(
            f"[fw-sort] Found {total} suspicious firmware symlink(s). "
            "Package ownership may be incomplete for these alias paths."
        )
    else:
        bb.note("[fw-sort] No suspicious firmware symlinks detected.")
