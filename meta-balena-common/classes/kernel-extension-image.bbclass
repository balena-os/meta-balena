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

# rootfs.py indexes against the base kernel on kirkstone and against every
# kernel in the shared pkgdata after it. Only the extension kernel belongs here.
USE_DEPMOD = "0"

# No userspace here, so /bin and /sbin would only shadow the hostapp's.
HOSTAPP_EXTENSION_REMOVE_PATHS:append = " bin sbin"

do_image[depends] += " \
    kmod-native:do_populate_sysroot \
    virtual/kernel-extension:do_deploy \
    virtual/kernel-extension:do_packagedata \
"

KERNEL_EXTENSION_DEPMOD_DIR = "${PKGDATA_DIR}/kernel-extension-depmod"

# :append so it runs after remove_unnecessary_files.
IMAGE_PREPROCESS_COMMAND:append = " finish_kernel_extension_modules;"

finish_kernel_extension_modules() {
    ABIFILE="${KERNEL_EXTENSION_DEPMOD_DIR}/kernel-extension-abiversion"
    [ -r "${ABIFILE}" ] || bbfatal "extension kernel release not found at ${ABIFILE}"
    KVER=$(cat "${ABIFILE}")
    SYSMAP="${KERNEL_EXTENSION_DEPMOD_DIR}/System.map-${KVER}"
    [ -r "${SYSMAP}" ] || bbfatal "extension kernel System.map not found at ${SYSMAP}"
    KVER_DIR="${IMAGE_ROOTFS}${nonarch_base_libdir}/modules/${KVER}"
    [ -d "${KVER_DIR}" ] || bbfatal "no ${nonarch_base_libdir}/modules/${KVER} in rootfs for the extension kernel"

    # Module.symvers is in no runtime package, but the ABI detection needs it.
    # A -dev package may already have laid it down.
    if [ ! -f "${KVER_DIR}/Module.symvers" ]; then
        SYMVERS="${KERNEL_EXTENSION_DEPLOY_DIR}/Module.symvers"
        [ -f "${SYMVERS}" ] || bbfatal "extension kernel Module.symvers not found at ${SYMVERS}"
        install -m 0644 "${SYMVERS}" "${KVER_DIR}/Module.symvers"
    fi

    # Keep the build host depmod.d out of the index.
    CONF="${WORKDIR}/depmod-extension.d"
    mkdir -p "${CONF}"

    bbnote "depmod against ${SYSMAP}"
    depmod -e -C "${CONF}" -b "${IMAGE_ROOTFS}" -F "${SYSMAP}" "${KVER}"
}
