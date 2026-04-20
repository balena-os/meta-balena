require efitools.inc

DEPENDS:append = " gnu-efi-native"

EXTRA_OEMAKE:append = " \
    INCDIR_PREFIX='${STAGING_DIR_NATIVE}' \
    CRTPATH_PREFIX='${STAGING_DIR_NATIVE}' \
"

SYSROOT_DIRS:append: = " ${bindir}"
do_populate_sysroot[cleandirs] = "${SYSROOT_DESTDIR}${bindir}"
inherit native
