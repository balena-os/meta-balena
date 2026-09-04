# kernel-ebpf.bbclass
#
# Gives a kernel what a CO-RE eBPF agent needs: BTF type information, the BPF
# core, the BPF LSM, and the kprobe/perf tracing surface.

inherit kernel-balena-override

# BPF_PROG_TYPE_LSM attaches through bpf_trampoline_link_prog, which arm32 does
# not implement
COMPATIBLE_HOST = "(x86_64|aarch64).*-linux"

# ebpf.cfg lives in this layer, not next to the recipe inheriting the class, so
# it has to be put on FILESPATH explicitly. Appended rather than prepended, so
# a device fragment of the same name still wins.
FILESEXTRAPATHS:append := ":${BALENA_COREBASE}/recipes-kernel/linux/files"

# :append rather than +=, because a recipe assigning
# KERNEL_BALENA_OVERRIDE_FRAGMENTS with a plain "=" would clobber a "+=", and
# the loss is silent: do_kernel_balena_verify_fragments derives its required
# symbols from the same variable it merges from, so a dropped fragment is
# neither merged nor missed and the build ships a kernel with no BTF.
KERNEL_BALENA_OVERRIDE_FRAGMENTS:append = " ebpf.cfg"

# CONFIG_DEBUG_INFO_BTF is gated in kconfig on PAHOLE_VERSION >= 121. Without
# pahole in the build olddefconfig drops it and the kernel is useless to a
# CO-RE agent, which do_kernel_balena_verify_fragments then reports.
DEPENDS += "pahole-native"

# ebpf.cfg forces CONFIG_DEBUG_INFO=y, and with compressed modules the standard
# strip does not reach debug symbols, so modules would ship full DWARF.
# INSTALL_MOD_STRIP=1 drops the debug sections while preserving .BTF.
do_install:prepend() {
    if grep -q '^CONFIG_MODULE_COMPRESS=y$' "${B}/.config"; then
        export INSTALL_MOD_STRIP=1
    fi
}

# To support the ebpf extension BSPs need to configure bpf in the LSM list.
# The LSM list varies between device type, so this layer cannot force it.
python do_kernel_ebpf_verify_lsm() {
    import os

    config = os.path.join(d.getVar("B"), ".config")
    lsm = kernel_balena_parse_config(config).get("CONFIG_LSM")
    if lsm is None:
        bb.fatal("kernel-ebpf: CONFIG_LSM is absent from %s, so the active LSM " % config)

    entries = [entry.strip() for entry in lsm.strip('"').split(",")]
    if "bpf" not in entries:
        bb.fatal("kernel-ebpf: CONFIG_LSM=%s does not list \"bpf\", so BPF LSM "
                 "programs cannot attach to this kernel. Add \"bpf\" to this "
                 "device's list; do not set CONFIG_LSM from ebpf.cfg, which "
                 "would replace the list and drop: %s"
                 % (lsm, ", ".join(entries)))
}
addtask kernel_ebpf_verify_lsm after do_kernel_balena_merge_fragments before do_compile
do_kernel_ebpf_verify_lsm[dirs] += "${B}"
