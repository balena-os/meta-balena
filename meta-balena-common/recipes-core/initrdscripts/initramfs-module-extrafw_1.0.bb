SUMMARY = "Add extra firmware search path to the kernel command line"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
RDEPENDS:${PN} = " \
    initramfs-framework-base \
    grub-editenv \
    os-helpers-logging \
    initramfs-module-mountboot \
"

inherit allarch

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI = "file://extrafw"

S = "${WORKDIR}"

do_install() {
    install -d ${D}/init.d
    install -m 0755 ${WORKDIR}/extrafw ${D}/init.d/81-extrafw
}

FILES:${PN} = "/init.d/81-extrafw"
