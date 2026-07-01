# kernel-balena-override.bbclass
#
# Late kernel config-fragment merge for kernel-OVERRIDE extensions.
#
# Discovery: an explicit, ordered list in KERNEL_BALENA_OVERRIDE_FRAGMENTS,
#            each resolved on FILESPATH. Never SRC_URI (that merges early).
# Timing:    merged after all BALENA_CONFIGS processing
#            (do_kernel_resin_checkconfig), so a fragment wins.
# Safety:    do_kernel_balena_verify_fragments asserts every requested symbol
#            landed, and re-asserts the signing posture, after the merge.

inherit kernel-balena

KERNEL_BALENA_OVERRIDE_FRAGMENTS ?= ""

def kernel_balena_override_fragments(d):
    names = (d.getVar("KERNEL_BALENA_OVERRIDE_FRAGMENTS") or "").split()
    filespath = d.getVar("FILESPATH") or ""
    resolved = []
    for name in names:
        path = bb.utils.which(filespath, name)
        if not path:
            bb.fatal("kernel-balena-override: fragment not found on FILESPATH: %s" % name)
        resolved.append(path)
    return resolved

def kernel_balena_parse_config(path):
    """Return {CONFIG_X: value} for every positively-set symbol in a kconfig
    file. '# CONFIG_X is not set' lines and other comments are ignored."""
    symbols = {}
    with open(path) as handle:
        for line in handle:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            symbols[key.strip()] = value.strip()
    return symbols

def kernel_balena_required_symbols(fragments, extra_symbols):
    """Symbols that must be present after the merge: every positive fragment
    entry (value != n) plus explicit CONFIG_X=value strings."""
    required = {}
    for fragment in fragments:
        for key, value in kernel_balena_parse_config(fragment).items():
            if value != "n":
                required[key] = value
    for symbol in extra_symbols:
        key, value = symbol.split("=", 1)
        required[key.strip()] = value.strip()
    return required

python do_kernel_balena_merge_fragments() {
    import os
    import subprocess

    fragments = kernel_balena_override_fragments(d)
    if not fragments:
        return

    S = d.getVar("S")
    B = d.getVar("B")
    base_config = os.path.join(B, ".config")

    make_cmd = d.getVar("KERNEL_MAKE_CMD") or "make"
    make_opts = d.getVar("EXTRA_OEMAKE") or ""
    arch = d.getVar("ARCH")
    if not arch:
        bb.fatal("kernel-balena-override: ARCH variable not set")

    bb.note("Merging %d kernel fragment(s):" % len(fragments))
    for f in fragments:
        bb.note("  %s" % f)

    merge_script = os.path.join(S, "scripts", "kconfig", "merge_config.sh")
    cmd = " ".join([merge_script, "-m", "-O", B, base_config] + fragments)
    ret = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if ret.returncode != 0:
        bb.fatal("merge_config.sh failed:\n%s" % ret.stderr)
    if ret.stderr:
        bb.note(ret.stderr)

    cmd = "%s %s -C %s O=%s ARCH=%s olddefconfig" % (make_cmd, make_opts, S, B, arch)
    bb.note("Running olddefconfig")
    ret = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if ret.returncode != 0:
        bb.fatal("olddefconfig failed:\n%s" % ret.stderr)
}
addtask kernel_balena_merge_fragments after do_kernel_resin_checkconfig before do_compile
do_kernel_balena_merge_fragments[dirs] += "${B}"

python do_kernel_balena_verify_fragments() {
    import os

    fragments = kernel_balena_override_fragments(d)
    if not fragments:
        return

    have = kernel_balena_parse_config(os.path.join(d.getVar("B"), ".config"))

    # Signing guard: when signing is enabled the secure-boot posture inherited
    # from BALENA_CONFIGS[secureboot] must survive the late fragment merge.
    extra = []
    if d.getVar("SIGN_API"):
        secureboot = d.getVarFlag("BALENA_CONFIGS", "secureboot") or ""
        extra = [s for s in secureboot.split() if "=" in s and not s.endswith("=n")]

    required = kernel_balena_required_symbols(fragments, extra)

    missing = []
    for key, value in sorted(required.items()):
        if have.get(key) != value:
            missing.append("%s=%s (found %s)" % (key, value, have.get(key, "unset")))

    if missing:
        bb.fatal("kernel-balena-override: required kernel config missing after merge:\n%s"
                 % "\n".join(missing))
}
addtask kernel_balena_verify_fragments after do_kernel_balena_merge_fragments before do_compile
do_kernel_balena_verify_fragments[dirs] += "${B}"

# Fold fragment content into the task hashes so a change re-runs the merge and
# the check. The verify logic itself lives in this class, so a change to it
# already rehashes the task through the normal bbclass code checksum.
python () {
    fragments = kernel_balena_override_fragments(d)
    if fragments:
        checksums = " " + " ".join("%s:True" % f for f in fragments)
        d.appendVarFlag("do_kernel_balena_merge_fragments", "file-checksums", checksums)
        d.appendVarFlag("do_kernel_balena_verify_fragments", "file-checksums", checksums)
}
