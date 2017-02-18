# Base this image on core-image-minimal
include recipes-core/images/core-image-minimal.bb

inherit image-resin

#
# The total space taken by resin is 700MiB (which includes all partitions but
# resin-data)
#
IMAGE_ROOTFS_SIZE = "315392"
IMAGE_OVERHEAD_FACTOR = "1.0"
IMAGE_ROOTFS_EXTRA_SPACE = "0"
# core-image-minimal adds 4M to IMAGE_ROOTFS_EXTRA_SPACE
# Make IMAGE_ROOTFS_MAXSIZE = IMAGE_ROOTFS_SIZE + 4M
IMAGE_ROOTFS_MAXSIZE = "319488"

# Generated resinhup-tar based on RESINHUP variable
IMAGE_FSTYPES = "${@bb.utils.contains('RESINHUP', 'yes', 'resinhup-tar', '', d)}"

IMAGE_FEATURES_append = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'development-image', 'debug-tweaks', '', d)} \
    splash \
    ssh-server-dropbear \
    read-only-rootfs \
    "

IMAGE_INSTALL_append = " \
    packagegroup-resin-debugtools \
    packagegroup-resin-connectivity \
    packagegroup-resin \
    "

generate_rootfs_fingerprints () {
    IGNORE_FILES=" \
        -not -name machine-id \
        -not -name ${RESIN_FINGERPRINT_FILENAME}.${RESIN_FINGERPRINT_EXT} \
        -not -name ld.so.cache \
        -not -name aux-cache"
    find ${IMAGE_ROOTFS} -xdev -type f $IGNORE_FILES -exec md5sum {} \; | sed "s#${IMAGE_ROOTFS}##g" | sort -k2 > ${IMAGE_ROOTFS}/${RESIN_FINGERPRINT_FILENAME}.${RESIN_FINGERPRINT_EXT}
}

generate_hostos_version () {
    echo "${HOSTOS_VERSION}" > ${DEPLOY_DIR_IMAGE}/VERSION_HOSTOS
}

IMAGE_PREPROCESS_COMMAND += " generate_rootfs_fingerprints ; "
IMAGE_POSTPROCESS_COMMAND += " generate_hostos_version ; "

RESIN_BOOT_PARTITION_FILES_append = " resin-logo.png:/splash/resin-logo.png"

# add the generated <machine-name>.json to the resin-boot partition, renamed as device-type.json
RESIN_BOOT_PARTITION_FILES_append = " ../../../../../${MACHINE}.json:/device-type.json"

# example NetworkManager config file
RESIN_BOOT_PARTITION_FILES_append = " system-connections/resin-sample:/system-connections/resin-sample"
