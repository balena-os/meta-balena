# kernel-extension.bbclass
#
# Turns a kernel recipe into the device's hostapp kernel extension: a second
# kernel, pinned independently of the base one and delivered as an overlay
# rather than in the rootfs. It carries no opinion about why the extension
# exists; inherit a capability class alongside it, kernel-ebpf for example.
#
# Inherit it below the device recipe's require chain, for the reason below.

# Brand this recipe as the extension kernel rather than a second provider of
# virtual/kernel. kernel.bbclass adds virtual/kernel to PROVIDES
# unconditionally and the require chain is what pulls that class in, so only a
# plain "=" evaluated afterwards drops it.
KERNEL_PACKAGE_NAME = "kernel-extension"
PROVIDES = "virtual/kernel-extension"

# Bundle the initramfs in a single pass, since stock do_bundle_initramfs
# compiles the whole kernel a second time to bake the initramfs in.
#
# Safe for an extension kernel and only for one: it leaves <imageType> and
# <imageType>.initramfs identical, and the extension consumes only the latter,
# through kernel-extension-image-initramfs.bb. A base kernel would end up
# deploying a plain image carrying an initramfs it should not have.
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
