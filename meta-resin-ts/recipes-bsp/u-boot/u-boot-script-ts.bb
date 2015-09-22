DESCRIPTION = "Create boot script for tsimx6 which handles resin structure"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
DEPENDS = "u-boot-mkimage-native"

inherit deploy

SRC_URI = "file://resin_sdboot.txt"

#S = "${WORKDIR}"

SD_BOOTSCRIPT ?= "resin_sdboot.txt"

do_compile () {
   uboot-mkimage -A arm -O linux -T script -C none -a 0 -e 0 \
                 -n "boot script" -d ${WORKDIR}/${SD_BOOTSCRIPT} \
                 ${B}/boot.ub
}

do_deploy () {
    install -d ${DEPLOYDIR}
    install ${B}/boot.ub ${DEPLOYDIR}/
}
addtask deploy before do_package after do_install

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "ts4900"
