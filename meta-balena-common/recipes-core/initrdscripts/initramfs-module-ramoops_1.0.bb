SUMMARY = "Pass a reserved ramoops region to the OS kernel command line"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
RDEPENDS:${PN} = " \
    initramfs-framework-base \
    os-helpers-logging \
"

inherit allarch

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI = "file://ramoops"

do_install() {
    install -d ${D}/init.d
    install -m 0755 ${UNPACKDIR}/ramoops ${D}/init.d/82-ramoops
}

FILES:${PN} = "/init.d/82-ramoops"
