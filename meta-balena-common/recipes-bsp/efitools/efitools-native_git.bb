require efitools.inc

DEPENDS:append = " gnu-efi-native"

EXTRA_OEMAKE:append = " \
    INCDIR_PREFIX='${STAGING_DIR_NATIVE}' \
    CRTPATH_PREFIX='${STAGING_DIR_NATIVE}' \
"

inherit native
