DESCRIPTION = "Resin custom INIT file - use for flashig internal devices from external ones"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r2"

SRC_URI = " \
    file://balena-init-flasher \
    file://balena-init-flasher.service \
    "
S = "${WORKDIR}"

inherit allarch systemd

SYSTEMD_SERVICE:${PN} = "balena-init-flasher.service"

DEPENDS += "balena-keys"

RDEPENDS:${PN} = " \
    bash \
    coreutils \
    util-linux \
    udev \
    resin-device-register \
    resin-device-progress \
    balena-init-board \
    parted \
    balena-init-flasher-board \
    util-linux-lsblk \
    "

RDEPENDS:${PN}:x86-64 = " \
    efitools-utils \
"

RDEPENDS:${PN}:append = "${@oe.utils.conditional('SIGN_API','','',' cryptsetup dosfstools e2fsprogs-mke2fs lvm2-udevrules os-helpers-fs os-helpers-tpm2 efivar',d)}"

# This should be just fine
BALENA_IMAGE ?= "balena-image-${MACHINE}.balenaos-img"

do_install() {
    if [ -z "${INTERNAL_DEVICE_KERNEL}" ]; then
        bbfatal "INTERNAL_DEVICE_KERNEL must be defined."
    fi

    if [ -n "${INTERNAL_DEVICE_BOOTLOADER_CONFIG}" ] && [ -z "${INTERNAL_DEVICE_BOOTLOADER_CONFIG_PATH}" ]; then
        bbfatal "INTERNAL_DEVICE_BOOTLOADER_CONFIG requires INTERNAL_DEVICE_BOOTLOADER_CONFIG_PATH to be set."
    fi

    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/balena-init-flasher ${D}${bindir}

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/balena-init-flasher.service ${D}${systemd_unitdir}/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@BASE_SBINDIR@,${base_sbindir},g' \
            -e 's,@SBINDIR@,${sbindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            -e 's,@SYS_CONFDIR@,${sysconfdir},g' \
            ${D}${systemd_unitdir}/system/balena-init-flasher.service
    fi

    # If bootloader needs to be flashed, we require the bootloader name and write offset
    if [ -n "${BOOTLOADER_FLASH_DEVICE}" ]; then
        if [ -z "${BOOTLOADER_IMAGE}" ] || [ -z "${BOOTLOADER_BLOCK_SIZE_OFFSET}" ] || [ -z "${BOOTLOADER_SKIP_OUTPUT_BLOCKS}" ]; then
            bbfatal "BOOTLOADER_FLASH_DEVICE requires BOOTLOADER_IMAGE, BOOTLOADER_BLOCK_SIZE_OFFSET and BOOTLOADER_SKIP_OUTPUT_BLOCKS."
        fi
    fi

    # Construct balena-init-flasher.conf
    install -d ${D}${sysconfdir}
    echo "INTERNAL_DEVICE_KERNEL=\"${INTERNAL_DEVICE_KERNEL}\"" >> ${D}/${sysconfdir}/balena-init-flasher.conf
    echo "INTERNAL_DEVICE_BOOTLOADER_CONFIG=${INTERNAL_DEVICE_BOOTLOADER_CONFIG}" >> ${D}/${sysconfdir}/balena-init-flasher.conf
    echo "INTERNAL_DEVICE_BOOTLOADER_CONFIG_PATH=${INTERNAL_DEVICE_BOOTLOADER_CONFIG_PATH}" >> ${D}/${sysconfdir}/balena-init-flasher.conf
    if [ -n "${INTERNAL_DEVICE_BOOTLOADER_LEGACY_CONFIG_PATH}" ]; then
        echo "INTERNAL_DEVICE_BOOTLOADER_LEGACY_CONFIG_PATH=${INTERNAL_DEVICE_BOOTLOADER_LEGACY_CONFIG_PATH}" >> ${D}/${sysconfdir}/balena-init-flasher.conf
    fi
    echo "BALENA_IMAGE=${BALENA_IMAGE}" >> ${D}/${sysconfdir}/balena-init-flasher.conf
    echo "BOOTLOADER_FLASH_DEVICE=${BOOTLOADER_FLASH_DEVICE}" >> ${D}/${sysconfdir}/balena-init-flasher.conf
    echo "BOOTLOADER_IMAGE=${BOOTLOADER_IMAGE}" >> ${D}/${sysconfdir}/balena-init-flasher.conf
    echo "BOOTLOADER_BLOCK_SIZE_OFFSET=${BOOTLOADER_BLOCK_SIZE_OFFSET}" >> ${D}/${sysconfdir}/balena-init-flasher.conf
    echo "BOOTLOADER_SKIP_OUTPUT_BLOCKS=${BOOTLOADER_SKIP_OUTPUT_BLOCKS}" >> ${D}/${sysconfdir}/balena-init-flasher.conf
    echo "BOOTLOADER_FLASH_DEVICE_1=${BOOTLOADER_FLASH_DEVICE_1}" >> ${D}/${sysconfdir}/balena-init-flasher.conf
    echo "BOOTLOADER_IMAGE_1=${BOOTLOADER_IMAGE_1}" >> ${D}/${sysconfdir}/balena-init-flasher.conf
    echo "BOOTLOADER_BLOCK_SIZE_OFFSET_1=${BOOTLOADER_BLOCK_SIZE_OFFSET_1}" >> ${D}/${sysconfdir}/balena-init-flasher.conf
    echo "BOOTLOADER_SKIP_OUTPUT_BLOCKS_1=${BOOTLOADER_SKIP_OUTPUT_BLOCKS_1}" >> ${D}/${sysconfdir}/balena-init-flasher.conf

    if [ "x${SIGN_API}" != "x" ]; then
        echo "INTERNAL_DEVICE_BOOTLOADER_CONFIG_LUKS=grub.cfg_internal_luks" >> ${D}/${sysconfdir}/balena-init-flasher.conf
    fi
}
