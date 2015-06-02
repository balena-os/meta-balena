FILESEXTRAPATHS_append := "${THISDIR}/${PN}:"
SRC_URI_append = " file://fix-hummingboard.patch"

# FIXME
# This is a bug in poky fido 13.0.0
# Is already fixed and will be included in the next fido release
# http://lists.openembedded.org/pipermail/openembedded-core/2015-April/103926.html
do_install_append_cubox-i () {
    for config in ${UBOOT_MACHINE}; do
        install ${S}/${config}/${SPL_BINARY} ${D}/boot/${SPL_IMAGE}-${UBOOT_CONFIG}-${PV}-${PR}
        ln -sf ${SPL_IMAGE}-${UBOOT_CONFIG}-${PV}-${PR} ${D}/boot/${SPL_BINARY}-${UBOOT_CONFIG}
        ln -sf ${SPL_IMAGE}-${UBOOT_CONFIG}-${PV}-${PR} ${D}/boot/${SPL_BINARY}
    done
}
do_deploy_append_cubox-i () {
    for config in ${UBOOT_MACHINE}; do
        install ${S}/${config}/${SPL_BINARY} ${DEPLOYDIR}/${SPL_IMAGE}-${UBOOT_CONFIG}-${PV}-${PR}
        rm -f ${DEPLOYDIR}/${SPL_BINARY} ${DEPLOYDIR}/${SPL_SYMLINK}-${UBOOT_CONFIG}
        ln -sf ${SPL_IMAGE}-${UBOOT_CONFIG}-${PV}-${PR} ${DEPLOYDIR}/${SPL_BINARY}-${UBOOT_CONFIG}
        ln -sf ${SPL_IMAGE}-${UBOOT_CONFIG}-${PV}-${PR} ${DEPLOYDIR}/${SPL_BINARY}
        ln -sf ${SPL_IMAGE}-${UBOOT_CONFIG}-${PV}-${PR} ${DEPLOYDIR}/${SPL_SYMLINK}-${UBOOT_CONFIG}
        ln -sf ${SPL_IMAGE}-${UBOOT_CONFIG}-${PV}-${PR} ${DEPLOYDIR}/${SPL_SYMLINK}
    done
}
