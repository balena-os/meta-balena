# kernel-ebpf.bbclass
#
# Gives a kernel what a CO-RE eBPF agent needs: BTF type information, the BPF
# core, the BPF LSM, and the kprobe/perf tracing surface.

inherit kernel-balena-override

# BPF_PROG_TYPE_LSM attaches through bpf_trampoline_link_prog, which arm32 lacks.
COMPATIBLE_HOST = "(x86_64|aarch64).*-linux"

# ebpf.cfg lives in this layer, not next to the inheriting recipe. Appended
# rather than prepended, so a device fragment of the same name still wins.
FILESEXTRAPATHS:append := ":${BALENA_COREBASE}/recipes-kernel/linux/files"

# :append rather than +=, which a recipe's plain "=" would clobber. The loss is
# silent: do_kernel_balena_verify_fragments derives its required symbols from
# the same variable, so a dropped fragment is neither merged nor missed.
KERNEL_BALENA_OVERRIDE_FRAGMENTS:append = " ebpf.cfg"

# CONFIG_DEBUG_INFO_BTF is gated on PAHOLE_VERSION >= 121, so without pahole
# olddefconfig drops it and the kernel carries no BTF.
DEPENDS += "pahole-native"

# The standard strip does not reach debug symbols in compressed modules, so
# with CONFIG_DEBUG_INFO=y they would ship full DWARF. INSTALL_MOD_STRIP drops
# the debug sections and preserves .BTF.
do_install:prepend() {
    if grep -q '^CONFIG_MODULE_COMPRESS=y$' "${B}/.config"; then
        export INSTALL_MOD_STRIP=1
    fi
}

# The LSM list varies by device type, so this layer cannot force bpf into it.
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
