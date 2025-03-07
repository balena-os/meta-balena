SUMMARY = "Resin image flasher"
IMAGE_LINGUAS = " "
LICENSE = "Apache-2.0"

inherit core-image image-balena features_check

REQUIRED_DISTRO_FEATURES += " systemd"

BALENA_FLAG_FILE = "${BALENA_FLASHER_FLAG_FILE}"

IMAGE_FSTYPES = "${@oe.utils.conditional('SIGN_API','','balenaos-img','balenaos-img.sig',d)}"

BALENA_ROOT_FSTYPE = "ext4"

# Make sure you have the resin image ready
do_image_balenaos_img[depends] += "balena-image:do_rootfs"

# Ensure we have the raw balena image ready in DEPLOY_DIR_IMAGE
do_image[depends] += "balena-image:do_image_complete"

IMAGE_FEATURES:append = " \
    splash \
    read-only-rootfs \
    ssh-server-openssh \
    "

IMAGE_INSTALL = " \
    packagegroup-core-boot \
    ${CORE_IMAGE_EXTRA_INSTALL} \
    packagegroup-balena-connectivity \
    packagegroup-resin-flasher \
    "

# Avoid useless space - no data or state on flasher
BALENA_DATA_FS = ""
BALENA_STATE_FS = ""

# We do not use a second root fs partition for the flasher image, so just default to BALENA_IMAGE_ALIGNMENT
BALENA_ROOTB_SIZE = "${BALENA_IMAGE_ALIGNMENT}"

# Avoid naming clash with resin image labels
BALENA_BOOT_FS_LABEL = "flash-boot"
BALENA_ROOTA_FS_LABEL = "flash-rootA"
BALENA_ROOTB_FS_LABEL = "flash-rootB"
BALENA_STATE_FS_LABEL = "flash-state"
BALENA_DATA_FS_LABEL = "flash-data"

# add the secure boot keys if needed
BALENA_BOOT_PARTITION_FILES:append = "${@oe.utils.conditional('SIGN_API','','',' balena-keys:/balena-keys/',d)}"

# add the LUKS variant of GRUB config if needed
BALENA_BOOT_PARTITION_FILES:append = "${@bb.utils.contains('MACHINE_FEATURES','efi',' grub.cfg_internal_luks:','',d)}"

# Put the resin logo, uEnv.txt files inside the boot partition
BALENA_BOOT_PARTITION_FILES:append = " balena-logo.png:/splash/balena-logo.png"

# add the generated <devicetype-name>.json to the flash-boot partition, renamed as device-type.json
BALENA_BOOT_PARTITION_FILES:append = " ${BALENA_COREBASE}/../../../${DEVICE_TYPE}.json:/device-type.json"

# Put balena-image in the flasher rootfs
add_resin_image_to_flasher_rootfs() {
    mkdir -p ${WORKDIR}/rootfs/opt
    cp ${DEPLOY_DIR_IMAGE}/balena-image-${MACHINE}.balenaos-img ${WORKDIR}/rootfs/opt
    if [ -n "${SIGN_API}" ]; then
        cp "${DEPLOY_DIR_IMAGE}/balena-image-${MACHINE}.balenaos-img.sig" "${WORKDIR}/rootfs/opt/"
    fi
}

IMAGE_PREPROCESS_COMMAND += " add_resin_image_to_flasher_rootfs; "

# example NetworkManager config file
BALENA_BOOT_PARTITION_FILES:append = " \
    system-connections/balena-sample.ignore:/system-connections/balena-sample.ignore \
    system-connections/README.ignore:/system-connections/README.ignore \
    "

# example redsocks config file
BALENA_BOOT_PARTITION_FILES:append = " \
    system-proxy/redsocks.conf.ignore:/system-proxy/redsocks.conf.ignore \
    system-proxy/README.ignore:/system-proxy/README.ignore \
"

# Resin flasher flag file
BALENA_BOOT_PARTITION_FILES:append = " ${BALENA_FLASHER_FLAG_FILE}:/${BALENA_FLASHER_FLAG_FILE}"
