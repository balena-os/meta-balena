SUMMARY = "Switch between rootA and rootB"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
RDEPENDS:${PN} = " \
    balena-config-vars-config \
    initramfs-framework-base \
    grub-editenv \
    util-linux-lsblk \
    os-helpers-logging \
    initramfs-module-mountboot \
"

inherit allarch

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI = "file://abroot"

do_install() {
    install -d ${D}/init.d
    install -m 0755 ${UNPACKDIR}/abroot ${D}/init.d/74-abroot
}

FILES:${PN} = "/init.d/74-abroot"
