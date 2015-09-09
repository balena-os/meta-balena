DESCRIPTION = "Resin custom INIT file - use for flashig internal devices from external ones"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r2"

SRC_URI = " \
    file://resin-init-flasher \
    file://resin-init-flasher.service \
    "
S = "${WORKDIR}"

inherit allarch systemd

SYSTEMD_SERVICE_${PN} = "resin-init-flasher.service"

RDEPENDS_${PN} = " \
    bash \
    coreutils \
    util-linux \
    udev \
    resin-device-progress \
    parted \
    "

# This should be just fine
RESIN_IMAGE ?= "resin-image-${MACHINE}.resin-sdcard"

do_install() {
    if [[ -z "${BOARD_BOOTLOADER}" || -z "${INTERNAL_DEVICE_KERNEL}" ]]; then
        bbfatal "One or more needed variables are not available in resin-init-flasher. \
            Usually these are provided with a bbappend. This can also mean that this \
            image is not usable for your selected MACHINE (${MACHINE})."
    fi
    if [[ "${BOARD_BOOTLOADER}" == "u-boot" && -z "${INTERNAL_DEVICE_UBOOT}" ]]; then
        bbfatal "INTERNAL_DEVICE_UBOOT must be defined."
    fi

    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/resin-init-flasher ${D}${bindir}

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/resin-init-flasher.service ${D}${systemd_unitdir}/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@BASE_SBINDIR@,${base_sbindir},g' \
            -e 's,@SBINDIR@,${sbindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            -e 's,@SYS_CONFDIR@,${sysconfdir},g' \
            ${D}${systemd_unitdir}/system/resin-init-flasher.service
    fi

    # Construct resin-init-flasher.conf
    install -d ${D}${sysconfdir}
    echo "BOARD_BOOTLOADER=${BOARD_BOOTLOADER}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "INTERNAL_DEVICE_KERNEL=${INTERNAL_DEVICE_KERNEL}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "INTERNAL_DEVICE_UBOOT=${INTERNAL_DEVICE_UBOOT}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "RESIN_IMAGE=${RESIN_IMAGE}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
}
