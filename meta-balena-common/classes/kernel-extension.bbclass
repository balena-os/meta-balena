# kernel-extension.bbclass
#
# Turns a kernel recipe into the device's hostapp kernel extension: a second
# kernel, pinned independently of the base one and delivered as an overlay
# rather than in the rootfs. It carries no opinion about why the extension
# exists; inherit a capability class alongside it, kernel-ebpf for example.
#
# Inherit it below the device recipe's require chain.

# Brand this as the extension kernel, not a second virtual/kernel provider.
# kernel.bbclass adds virtual/kernel to PROVIDES unconditionally, so only a
# plain "=" evaluated after the require chain drops it.
KERNEL_PACKAGE_NAME = "kernel-extension"
PROVIDES = "virtual/kernel-extension"

# Bundle the initramfs in one pass; stock do_bundle_initramfs compiles the
# whole kernel a second time. Safe for an extension kernel and only for one:
# it leaves <imageType> and <imageType>.initramfs identical, and a base kernel
# would deploy a plain image carrying an initramfs it should not have.
KERNEL_EXTRA_ARGS:append = " CONFIG_INITRAMFS_SOURCE=${B}/usr/${INITRAMFS_IMAGE_NAME}.cpio"

# An empty INITRAMFS_IMAGE here is a parse error rather than a no-op.
do_compile[depends] += "${@'${INITRAMFS_IMAGE}:do_image_complete' if d.getVar('INITRAMFS_IMAGE') else ''}"

do_compile:prepend() {
    copy_initramfs
}

do_bundle_initramfs() {
    for imageType in ${KERNEL_IMAGETYPE_FOR_MAKE}; do
        cp -fL ${KERNEL_OUTPUT_DIR}/$imageType ${KERNEL_OUTPUT_DIR}/$imageType.initramfs
    done
}
