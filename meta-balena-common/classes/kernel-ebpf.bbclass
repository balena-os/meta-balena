# kernel-ebpf.bbclass
#
# Gives a kernel what a CO-RE eBPF agent needs: BTF type information, the BPF
# core, the BPF LSM, and the kprobe/perf tracing surface.

inherit kernel-balena-override

# BPF_PROG_TYPE_LSM attaches through bpf_trampoline_link_prog, which arm32 does
# not implement: CONFIG_BPF_LSM=y builds cleanly there and then fails every
# attach at runtime with -ENOTSUPP.
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
