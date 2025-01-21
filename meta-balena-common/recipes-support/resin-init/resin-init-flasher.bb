DESCRIPTION = "Resin custom INIT file - use for flashig internal devices from external ones"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r2"

SRC_URI = " \
    file://resin-init-flasher \
    file://resin-init-flasher.service \
    "

SRC_URI:append = " \
           ${@bb.utils.contains('MACHINE_FEATURES', 'efi', ' file://balena-init-flasher-efi', '',d)} \
           ${@bb.utils.contains('MACHINE_FEATURES', 'tpm', ' file://balena-init-flasher-tpm', '',d)} \
"

S = "${WORKDIR}"

inherit allarch systemd

SYSTEMD_SERVICE:${PN} = "resin-init-flasher.service"

DEPENDS += "${@oe.utils.conditional('SIGN_API','','',' balena-keys',d)}"

RDEPENDS:${PN} = " \
    bash \
    coreutils \
    udev \
    resin-init-board \
    parted \
    resin-init-flasher-board \
    util-linux-lsblk \
    "

RDEPENDS:${PN}:append = "${@bb.utils.contains('MACHINE_FEATURES', 'efi', ' efitools-utils efibootmgr efivar', '',d)}"
RDEPENDS:${PN}:append = "${@bb.utils.contains('MACHINE_FEATURES', 'tpm', ' os-helpers-tpm2', '',d)}"

RDEPENDS:${PN}:append = "${@oe.utils.conditional('SIGN_API','','',' cryptsetup dosfstools e2fsprogs-mke2fs lvm2-udevrules os-helpers-fs util-linux-mount util-linux-losetup openssl-bin',d)}"

# This should be just fine
BALENA_IMAGE ?= "balena-image-${MACHINE}.balenaos-img"

do_install[depends] += "jq-native:do_populate_sysroot"
do_install() {
    if [ -z "${INTERNAL_DEVICE_KERNEL}" ]; then
        bbwarn "INTERNAL_DEVICE_KERNEL is not defined - some features like migration will not work."
    fi

    if [ -n "${INTERNAL_DEVICE_BOOTLOADER_CONFIG}" ] && [ -z "${INTERNAL_DEVICE_BOOTLOADER_CONFIG_PATH}" ]; then
        bbfatal "INTERNAL_DEVICE_BOOTLOADER_CONFIG requires INTERNAL_DEVICE_BOOTLOADER_CONFIG_PATH to be set."
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
        if [ -z "${BOOTLOADER_IMAGE}" ] || [ -z "${BOOTLOADER_BLOCK_SIZE_OFFSET}" ] || [ -z "${BOOTLOADER_SKIP_OUTPUT_BLOCKS}" ]; then
            bbfatal "BOOTLOADER_FLASH_DEVICE requires BOOTLOADER_IMAGE, BOOTLOADER_BLOCK_SIZE_OFFSET and BOOTLOADER_SKIP_OUTPUT_BLOCKS."
        fi
    fi

    # Construct resin-init-flasher.conf
    install -d ${D}${sysconfdir}
    echo "INTERNAL_DEVICE_KERNEL=\"${INTERNAL_DEVICE_KERNEL}\"" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "INTERNAL_DEVICE_BOOTLOADER_CONFIG=${INTERNAL_DEVICE_BOOTLOADER_CONFIG}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "INTERNAL_DEVICE_BOOTLOADER_CONFIG_PATH=${INTERNAL_DEVICE_BOOTLOADER_CONFIG_PATH}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    if [ -n "${INTERNAL_DEVICE_BOOTLOADER_LEGACY_CONFIG_PATH}" ]; then
        echo "INTERNAL_DEVICE_BOOTLOADER_LEGACY_CONFIG_PATH=${INTERNAL_DEVICE_BOOTLOADER_LEGACY_CONFIG_PATH}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    fi
    echo "BALENA_IMAGE=${BALENA_IMAGE}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "BOOTLOADER_FLASH_DEVICE=${BOOTLOADER_FLASH_DEVICE}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "BOOTLOADER_IMAGE=${BOOTLOADER_IMAGE}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "BOOTLOADER_BLOCK_SIZE_OFFSET=${BOOTLOADER_BLOCK_SIZE_OFFSET}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "BOOTLOADER_SKIP_OUTPUT_BLOCKS=${BOOTLOADER_SKIP_OUTPUT_BLOCKS}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "BOOTLOADER_FLASH_DEVICE_1=${BOOTLOADER_FLASH_DEVICE_1}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "BOOTLOADER_IMAGE_1=${BOOTLOADER_IMAGE_1}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "BOOTLOADER_BLOCK_SIZE_OFFSET_1=${BOOTLOADER_BLOCK_SIZE_OFFSET_1}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "BOOTLOADER_SKIP_OUTPUT_BLOCKS_1=${BOOTLOADER_SKIP_OUTPUT_BLOCKS_1}" >> ${D}/${sysconfdir}/resin-init-flasher.conf

    if [ "x${SIGN_API}" != "x" ]; then
        echo "USE_LUKS=${BALENA_USE_LUKS}" >> ${D}/${sysconfdir}/resin-init-flasher.conf
        if ${@bb.utils.contains('MACHINE_FEATURES','efi','true','false',d)}; then
            install -d ${D}${libexecdir}
            echo "INTERNAL_DEVICE_BOOTLOADER_CONFIG_LUKS=grub.cfg_internal_luks" >> ${D}/${sysconfdir}/resin-init-flasher.conf
            install -m 0755 ${WORKDIR}/balena-init-flasher-efi ${D}${libexecdir}/balena-init-flasher-secureboot
            sed -i -e 's,@@KERNEL_IMAGETYPE@@,${KERNEL_IMAGETYPE},' ${D}${libexecdir}/balena-init-flasher-secureboot
        fi
        if ${@bb.utils.contains('MACHINE_FEATURES','tpm','true','false',d)}; then
            install -d ${D}${libexecdir}
            install -m 0755 ${WORKDIR}/balena-init-flasher-tpm ${D}${libexecdir}/balena-init-flasher-diskenc
        fi
    fi

    # Configuration data
    echo "BALENA_SPLASH_CONFIG=splash" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "BALENA_BOOTLOADER_CONFIG=resinOS_uEnv.txt" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "BALENA_NM_CONFIG=system-connections" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "BALENA_NM_DISPATCHER=dispatcher.d" >> ${D}/${sysconfdir}/resin-init-flasher.conf
    echo "BALENA_PROXY_CONFIG=system-proxy" >> ${D}/${sysconfdir}/resin-init-flasher.conf
}
