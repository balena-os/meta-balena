SUMMARY = "Apply extra boot params during stage 2 boot"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
RDEPENDS:${PN} = "initramfs-framework-base grub-editenv util-linux-lsblk os-helpers-logging"

inherit allarch

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI = "file://extraenv_bootparams"

S = "${WORKDIR}"

do_install() {
    install -d ${D}/init.d
    install -m 0755 ${WORKDIR}/extraenv_bootparams ${D}/init.d/91-extraenv_bootparams
    sed -i "s|@@ALLOWED_BOOTARGS@@|${@format_bootargs_array(d)}|g" ${D}/init.d/91-extraenv_bootparams
}

RDEPENDS:${PN}:append = " balena-config-vars-config"
FILES:${PN} = "/init.d/91-extraenv_bootparams"
