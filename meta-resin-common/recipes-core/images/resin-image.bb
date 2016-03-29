# Base this image on core-image-minimal
include recipes-core/images/core-image-minimal.bb

#
# Set size of rootfs at a fixed value of maximum 180MiB
#

# keep this aligned to IMAGE_ROOTFS_ALIGNMENT
IMAGE_ROOTFS_SIZE = "180224"

# No overhead factor
IMAGE_OVERHEAD_FACTOR = "1.0"

# No extra space
IMAGE_ROOTFS_EXTRA_SPACE = "0"

# core-image-minimal add 4M to IMAGE_ROOTFS_EXTRA_SPACE
# Make IMAGE_ROOTFS_MAXSIZE = IMAGE_ROOTFS_SIZE + 4M
IMAGE_ROOTFS_MAXSIZE = "184320"


# Generated resinhup-tar based on RESINHUP variable
IMAGE_FSTYPES = "${@bb.utils.contains('RESINHUP', 'yes', 'resinhup-tar', '', d)}"

IMAGE_FEATURES_append = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'resin-staging', 'debug-tweaks', '', d)} \
    splash \
    ssh-server-dropbear \
    "

IMAGE_INSTALL_append = " \
    packagegroup-resin-connectivity \
    packagegroup-resin \
    "

generate_rootfs_fingerprints () {
    find ${IMAGE_ROOTFS} -xdev -type f -exec md5sum {} \; | sed "s#${IMAGE_ROOTFS}##g" | sort -k2 > ${IMAGE_ROOTFS}/${RESIN_ROOT_FS_LABEL}.${FINGERPRINT_EXT}
}

generate_hostos_version () {
    echo ${DISTRO_VERSION} > ${DEPLOY_DIR_IMAGE}/VERSION_HOSTOS
}

ROOTFS_POSTPROCESS_COMMAND += " generate_rootfs_fingerprints ; "
IMAGE_POSTPROCESS_COMMAND += " generate_hostos_version ; "

RESIN_BOOT_PARTITION_FILES_append = " resin-logo.png:/splash/resin-logo.png"
