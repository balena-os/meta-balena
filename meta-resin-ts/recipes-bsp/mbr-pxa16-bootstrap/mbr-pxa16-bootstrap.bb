DESCRIPTION = "MBR bootstrap"
LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
SECTION = "Bootloader"
PROVIDES = "virtual/bootloader"

SRC_URI = "file://bootstrap-code.img"
S = "${WORKDIR}"

inherit deploy

do_deploy () {
    install -d ${DEPLOYDIR}
    install ${S}/bootstrap-code.img ${DEPLOYDIR}
}

addtask deploy after do_install before do_build

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "ts7700"
