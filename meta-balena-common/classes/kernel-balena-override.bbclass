# kernel-balena-override.bbclass
#
# Late kernel config-fragment merge for kernel-OVERRIDE extensions.
#
# Discovery: every *.cfg in any FILESEXTRAPATHS dir.
# Timing: merged after all BALENA_CONFIGS processing (do_kernel_resin_checkconfig), so a fragment wins.
# Tracking: the same *.cfg set is registered as [file-checksums] on the merge task

inherit kernel-balena

python do_kernel_balena_merge_fragments() {
    import glob
    import os
    import subprocess

    S = d.getVar("S")
    B = d.getVar("B")
    base_config = os.path.join(B, ".config")

    make_cmd = d.getVar("KERNEL_MAKE_CMD") or "make"
    make_opts = d.getVar("EXTRA_OEMAKE") or ""
    arch = d.getVar("ARCH")
    if not arch:
        bb.fatal("kernel-balena-override: ARCH variable not set")

    fragments = []
    seen = set()
    filesextrapaths = d.getVar("FILESEXTRAPATHS") or ""
    for path in filesextrapaths.split(":"):
        if not path:
            continue
        for cfg in sorted(glob.glob(os.path.join(path, "*.cfg"))):
            if cfg not in seen:
                seen.add(cfg)
                fragments.append(cfg)

    if not fragments:
        return

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

# Fold fragment *.cfg content into the merge task's signature (same scope as the
# runtime glob above).
python () {
    fep = (d.getVar("FILESEXTRAPATHS") or "").split(":")
    patterns = " ".join("%s/*.cfg:True" % p.rstrip("/") for p in fep if p)
    if patterns:
        d.appendVarFlag("do_kernel_balena_merge_fragments", "file-checksums", " " + patterns)
}
