DESCRIPTION = "Resin custom INIT file - use for flashig internal devices from external ones"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r0"

SRC_URI = " file://resin-init-flasher"

inherit update-rc.d allarch

INITSCRIPT_NAME = "resin-init-flasher"
INITSCRIPT_PARAMS = "start 06 5 ."

FILES_${PN} = "${sysconfdir}/*"
RDEPENDS_${PN} = " \
    bash \
    coreutils \
    util-linux \
    udev \
    "

# This should be just fine
RESIN_IMAGE ?= "resin-image-${MACHINE}.resin-sdcard"

python () {
    if not d.getVar('INTERNAL_DEVICE_KERNEL', True) or not d.getVar('INTERNAL_DEVICE_UBOOT', True):
        bb.fatal("One or more needed variables are not available in resin-init-flasher. Usually these are provided with a bbappend.")
}

do_install() {
    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${WORKDIR}/resin-init-flasher  ${D}${sysconfdir}/init.d/

    # Construct resin-init-flasher.conf
    echo "INTERNAL_DEVICE_KERNEL=${INTERNAL_DEVICE_KERNEL}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "INTERNAL_DEVICE_UBOOT=${INTERNAL_DEVICE_UBOOT}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "RESIN_IMAGE=${RESIN_IMAGE}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
}
