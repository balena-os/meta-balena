# kernel-extension-image.bbclass
#
# Packages the extension kernel and its modules as a hostapp overlay. Inherit
# it from an image recipe and append whatever userspace the extension exists to
# deliver.

inherit balena-hostapp-extension

# :append for the reason balena-hostapp-extension.bbclass gives. Here the
# silent result is an extension imported with no kernel content at all.
IMAGE_INSTALL:append = " kernel-extension-modules kernel-extension-image-initramfs"

# x86 device types have no devicetree to package.
IMAGE_INSTALL:append = " ${@'kernel-extension-devicetree' if d.getVar('KERNEL_DEVICETREE') else ''}"

# Mounts left of the hostapp in mobynit's overlay stack. 100 leaves headroom
# both directions for overlays that shadow or are shadowed by this one.
HOSTAPP_EXTENSION_LABEL_OVERRIDE = "100"

# Fixed upstream in openembedded-core efa88e1c227d ("rootfs.py: Run
# depmod(wrapper) against each compiled kernel"); revisit once the poky
# submodule moves off kirkstone.
USE_DEPMOD = "0"

# No userspace here, so /bin and /sbin would only shadow the hostapp's.
HOSTAPP_EXTENSION_REMOVE_PATHS:append = " bin sbin"

# The base kernel usually shares the upstream version, so pick by deploy
# directory, never by version.
KERNEL_EXTENSION_DEPLOY_DIR = "${DEPLOY_DIR_IMAGE}/kernel-extension"
do_rootfs[depends] += "virtual/kernel-extension:do_deploy"

# :append so it runs after remove_unnecessary_files.
IMAGE_PREPROCESS_COMMAND:append = " install_kernel_extension_symvers;"

# Module.symvers is in no runtime package, but the ABI detection needs it.
install_kernel_extension_symvers() {
    KVER_DIR=$(find "${IMAGE_ROOTFS}/usr/lib/modules" "${IMAGE_ROOTFS}/lib/modules" \
        -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort -u | head -n1)
    [ -n "${KVER_DIR}" ] || \
        bbfatal "no /lib/modules/<ver>/ in rootfs for the extension kernel"

    # A -dev package already laid it down.
    [ ! -f "${KVER_DIR}/Module.symvers" ] || return 0

    SYMVERS="${KERNEL_EXTENSION_DEPLOY_DIR}/Module.symvers"
    [ -f "${SYMVERS}" ] || bbfatal "extension kernel Module.symvers not found at ${SYMVERS}"
    install -m 0644 "${SYMVERS}" "${KVER_DIR}/Module.symvers"
}
