SUMMARY = "Resin image flasher"
IMAGE_LINGUAS = " "
LICENSE = "Apache-2.0"

inherit core-image image-resin distro_features_check

REQUIRED_DISTRO_FEATURES += " systemd"

RESIN_FLAG_FILE = "${RESIN_FLASHER_FLAG_FILE}"

# Each machine should append this with their specific configuration
IMAGE_FSTYPES = ""

RESIN_ROOT_FSTYPE = "ext4"

# Make sure you have the resin image ready
IMAGE_DEPENDS_resinos-img_append = " resin-image:do_rootfs"

IMAGE_FEATURES_append = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'development-image', 'debug-tweaks', '', d)} \
    splash \
    read-only-rootfs \
    ssh-server-dropbear \
    "

IMAGE_INSTALL = " \
    packagegroup-core-boot \
    ${CORE_IMAGE_EXTRA_INSTALL} \
    packagegroup-resin-connectivity \
    packagegroup-resin-flasher \
    "

# Avoid useless space - no data or state on flasher
RESIN_DATA_FS = ""
RESIN_STATE_FS = ""

# We do not use a second root fs partition for the flasher image, so just default to RESIN_IMAGE_ALIGNMENT
RESIN_ROOTB_SIZE = "${RESIN_IMAGE_ALIGNMENT}"

# Avoid naming clash with resin image labels
RESIN_BOOT_FS_LABEL = "flash-boot"
RESIN_ROOTA_FS_LABEL = "flash-rootA"
RESIN_ROOTB_FS_LABEL = "flash-rootB"
RESIN_STATE_FS_LABEL = "flash-state"
RESIN_DATA_FS_LABEL = "flash-data"

# Put the resin logo, uEnv.txt files inside the boot partition
RESIN_BOOT_PARTITION_FILES_append = " resin-logo.png:/splash/resin-logo.png"

# add the generated <machine-name>.json to the flash-boot partition, renamed as device-type.json
RESIN_BOOT_PARTITION_FILES_append = " ../../../../../${MACHINE}.json:/device-type.json"

# Put resin-image in the flasher rootfs
add_resin_image_to_flasher_rootfs() {
    mkdir -p ${WORKDIR}/rootfs/opt
    cp ${DEPLOY_DIR_IMAGE}/resin-image-${MACHINE}.resinos-img ${WORKDIR}/rootfs/opt
}

IMAGE_PREPROCESS_COMMAND += " add_resin_image_to_flasher_rootfs; "

# example NetworkManager config file
RESIN_BOOT_PARTITION_FILES_append = " \
    system-connections/resin-sample.ignore:/system-connections/resin-sample.ignore \
    system-connections/README.ignore:/system-connections/README.ignore \
    "

# Resin flasher flag file
RESIN_BOOT_PARTITION_FILES_append = " ${RESIN_FLASHER_FLAG_FILE}:/${RESIN_FLASHER_FLAG_FILE}"
