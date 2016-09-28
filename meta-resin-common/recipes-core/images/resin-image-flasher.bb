# Base this image on core-image-minimal
include recipes-core/images/core-image-minimal.bb

inherit image-resin

# Each machine should append this with their specific configuration
IMAGE_FSTYPES = ""

# Make sure you have the resin image ready
IMAGE_DEPENDS_resin-sdcard_append = " resin-image:do_rootfs"

IMAGE_FEATURES_append = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'development-image', 'debug-tweaks', '', d)} \
    splash \
    "

IMAGE_INSTALL_append = " \
    packagegroup-resin-connectivity \
    packagegroup-resin-flasher \
    "

# Avoid useless space by not using any btrfs partition
BTRFS_IMAGE = ""

# We do not use a back-up rootfs partition for the flasher image, so just default to IMAGE_ROOTFS_ALIGNMENT size
UPDATE_SIZE_ALIGNED = "${IMAGE_ROOTFS_ALIGNMENT}"

# Avoid naming clash with resin image labels
RESIN_BOOT_FS_LABEL = "flash-boot"
RESIN_ROOT_FS_LABEL = "flash-root"
RESIN_UPDATE_FS_LABEL = "flash-updt"
RESIN_CONFIG_FS_LABEL = "flash-conf"

# Put the resin logo, uEnv.txt files inside the boot partition
RESIN_BOOT_PARTITION_FILES_append = " resin-logo.png:/splash/resin-logo.png"

# add the generated <machine-name>.json to the flash-boot partition, renamed as device-type.json
RESIN_BOOT_PARTITION_FILES_append = " ../../../../../${MACHINE}.json:/device-type.json"

# Put resin-image in the flasher rootfs
add_resin_image_to_flasher_rootfs() {
    mkdir -p ${WORKDIR}/rootfs/opt
    cp ${DEPLOY_DIR_IMAGE}/resin-image-${MACHINE}.resin-sdcard ${WORKDIR}/rootfs/opt
}

IMAGE_PREPROCESS_COMMAND += " add_resin_image_to_flasher_rootfs; "
