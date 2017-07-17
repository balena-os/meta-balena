SUMMARY = "Resin image"
IMAGE_LINGUAS = " "
LICENSE = "Apache-2.0"

inherit core-image image-resin

RESIN_FLAG_FILE = "${RESIN_IMAGE_FLAG_FILE}"

#
# The default root filesystem partition size is set in such a way that the
# entire space taken by resinOS would not exceed 700 MiB. This  can be
# overwritten by board specific layers.
#
IMAGE_ROOTFS_SIZE = "319488"
IMAGE_OVERHEAD_FACTOR = "1.0"
IMAGE_ROOTFS_EXTRA_SPACE = "0"
IMAGE_ROOTFS_MAXSIZE = "${IMAGE_ROOTFS_SIZE}"

# Generated resinhup-tar based on RESINHUP variable
IMAGE_FSTYPES = "${@bb.utils.contains('RESINHUP', 'yes', 'tar', '', d)}"

IMAGE_FEATURES_append = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'development-image', 'debug-tweaks', '', d)} \
    splash \
    ssh-server-dropbear \
    read-only-rootfs \
    "

IMAGE_INSTALL = " \
    packagegroup-core-boot \
    ${ROOTFS_PKGMANAGE_BOOTSTRAP} \
    ${CORE_IMAGE_EXTRA_INSTALL} \
    packagegroup-resin-debugtools \
    packagegroup-resin-connectivity \
    packagegroup-resin \
    "

generate_rootfs_fingerprints () {
    find ${IMAGE_ROOTFS} -xdev -type f \
        -not -name ${RESIN_FINGERPRINT_FILENAME}.${RESIN_FINGERPRINT_EXT} \
        -exec md5sum {} \; | sed "s#${IMAGE_ROOTFS}##g" | \
        sort -k2 > ${IMAGE_ROOTFS}/${RESIN_FINGERPRINT_FILENAME}.${RESIN_FINGERPRINT_EXT}
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

# Resin image flag file
RESIN_BOOT_PARTITION_FILES_append = " ${RESIN_IMAGE_FLAG_FILE}:/${RESIN_IMAGE_FLAG_FILE}"
