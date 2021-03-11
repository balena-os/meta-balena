SUMMARY = "Grub configuration and other various files"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://grub.cfg_external_template \
    file://grub.cfg_internal_template \
    file://grubenv \
    "

inherit deploy nopackages

INHIBIT_DEFAULT_DEPS = "1"
BOOTLOADER_TIMEOUT = "${@bb.utils.contains('OS_DEV_GRUB_DELAY', '1', '3', '0', d)}"

do_configure[noexec] = '1'
do_compile() {
    sed -e 's/@@TIMEOUT@@/${BOOTLOADER_TIMEOUT}/' \
        -e 's/@@KERNEL_IMAGETYPE@@/${KERNEL_IMAGETYPE}/' \
        -e 's/@@KERNEL_CMDLINE@@/rootwait ${OS_KERNEL_CMDLINE} ${MACHINE_SPECIFIC_EXTRA_CMDLINE}/' \
        "${WORKDIR}/grub.cfg_internal_template" > "${B}/grub.cfg_internal"

    sed -e 's/@@TIMEOUT@@/${BOOTLOADER_TIMEOUT}/' \
        -e 's/@@KERNEL_IMAGETYPE@@/${KERNEL_IMAGETYPE}/' \
	-e 's/@@KERNEL_CMDLINE@@/rootwait ${OS_KERNEL_CMDLINE} ${MACHINE_SPECIFIC_EXTRA_CMDLINE}/' \
        "${WORKDIR}/grub.cfg_external_template" > "${B}/grub.cfg_external"

}
do_install[noexec] = '1'
do_deploy() {
    install -m 644 ${B}/grub.cfg_external ${DEPLOYDIR}
    install -m 644 ${B}/grub.cfg_internal ${DEPLOYDIR}

    install -m 644 ${WORKDIR}/grubenv ${DEPLOYDIR}/grubenv
    touch ${DEPLOYDIR}/grub_extraenv

}

addtask do_deploy before do_package after do_install
