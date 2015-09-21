DESCRIPTION = "Create boot script for tsimx6 which handles resin structure"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
DEPENDS = "u-boot-mkimage-native"

S = "${WORKDIR}"

inherit deploy

SRC_URI = "file://resin_sdboot.txt"

SD_BOOTSCRIPT ?= "resin_sdboot.txt"

do_mkimage () {
   uboot-mkimage -A arm -O linux -T script -C none -a 0 -e 0 \
                 -n "boot script" -d ${SD_BOOTSCRIPT} \
                 boot.ub
}

addtask mkimage after do_compile before do_install

do_deploy () {
    install -d ${DEPLOYDIR}
    install ${S}/boot.ub ${DEPLOYDIR}/
}

addtask deploy after do_install before do_build

do_compile[noexec] = "1"
do_install[noexec] = "1"
do_package[noexec] = "1"
do_package_write_rpm[noexec] = "1"
do_populate_sysroot[noexec] = "1"

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "ts4900"
