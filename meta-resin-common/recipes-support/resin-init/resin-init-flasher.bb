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
    if [[ -z "${INTERNAL_DEVICE_KERNEL}" ]]; then
        bbfatal "INTERNAL_DEVICE_KERNEL must be defined."
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

    # If bootloader needs to be flashed, we require the bootloader name and write offset
    if [ -n "${BOOTLOADER_FLASH_DEVICE}" ]; then
        if [ -z "${BOOTLOADER_IMAGE}" || -z "${BOOTLOADER_BLOCK_SIZE_OFFSET}" || -z "${BOOTLOADER_SKIP_OUTPUT_BLOCKS}" ]]; then
            bbfatal "BOOTLOADER_FLASH_DEVICE requires BOOTLOADER_IMAGE, BOOTLOADER_BLOCK_SIZE_OFFSET and BOOTLOADER_SKIP_OUTPUT_BLOCKS."
        fi
    fi

    # Construct resin-init-flasher.conf
    install -d ${D}${sysconfdir}
    echo "BOARD_BOOTLOADER=${BOARD_BOOTLOADER}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "INTERNAL_DEVICE_KERNEL=${INTERNAL_DEVICE_KERNEL}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "INTERNAL_DEVICE_UBOOT=${INTERNAL_DEVICE_UBOOT}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "RESIN_IMAGE=${RESIN_IMAGE}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "BOOTLOADER_FLASH_DEVICE=${BOOTLOADER_FLASH_DEVICE}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "BOOTLOADER_IMAGE=${BOOTLOADER_IMAGE}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "BOOTLOADER_BLOCK_SIZE_OFFSET=${BOOTLOADER_BLOCK_SIZE_OFFSET}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "BOOTLOADER_SKIP_OUTPUT_BLOCKS=${BOOTLOADER_SKIP_OUTPUT_BLOCKS}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
}
