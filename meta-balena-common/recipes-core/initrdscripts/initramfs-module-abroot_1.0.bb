SUMMARY = "Switch between rootA and rootB"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
RDEPENDS:${PN} = "initramfs-framework-base grub-editenv util-linux-lsblk"

inherit allarch

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI = "file://abroot"

S = "${WORKDIR}"

do_install() {
    install -d ${D}/init.d
    install -m 0755 ${WORKDIR}/abroot ${D}/init.d/73-abroot
    sed -i "s/@@BALENA_NONENC_BOOT_LABEL@@/${BALENA_NONENC_BOOT_LABEL}/g" ${D}/init.d/73-abroot
}

FILES:${PN} = "/init.d/73-abroot"
