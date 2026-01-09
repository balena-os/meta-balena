SUMMARY = "Find and mount boot partition for the balena bootloader"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
RDEPENDS:${PN} = " \
    balena-config-vars-config \
    initramfs-framework-base \
    util-linux-lsblk \
    os-helpers-logging \
"

inherit allarch

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI = "file://mountboot"

S = "${WORKDIR}"

do_install() {
    install -d ${D}/init.d
    install -m 0755 ${WORKDIR}/mountboot ${D}/init.d/73-mountboot
}

FILES:${PN} = "/init.d/73-mountboot"
