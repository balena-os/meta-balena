SUMMARY = "Resin image"
IMAGE_LINGUAS = " "
LICENSE = "Apache-2.0"

REQUIRED_DISTRO_FEATURES += " systemd"

RESIN_FLAG_FILE = "${RESIN_IMAGE_FLAG_FILE}"

def disk_aligned(d, rootfs_size, rfs_alignment):
    saved_rootfs_size = rootfs_size
    rootfs_size += rfs_alignment - 1
    rootfs_size -= rootfs_size % rfs_alignment
    bb.debug(1, 'requested rootfs size %d, aligned %d' % (saved_rootfs_size, rootfs_size) )
    return rootfs_size

# The rootfs size is calculated by substracting the size of all other partitions
# except the data partition, dividing by 2, and substracting filesystem metadata
# and reserved allocations
def balena_rootfs_size(d):
    boot_part_size = int(d.getVar("RESIN_BOOT_SIZE"))
    state_part_size = int(d.getVar("RESIN_STATE_SIZE"))
    rfs_alignment = int(d.getVar("IMAGE_ROOTFS_ALIGNMENT"))
    balena_rootfs_size = int((700000 - boot_part_size - state_part_size) / 2)
    return int(disk_aligned(d, balena_rootfs_size, rfs_alignment))

#
# The default root filesystem partition size is set in such a way that the
# entire space taken by resinOS would not exceed 700 MiB. This  can be
# overwritten by board specific layers.

IMAGE_ROOTFS_SIZE = "${@balena_rootfs_size(d)}"
IMAGE_OVERHEAD_FACTOR = "1.0"
IMAGE_ROOTFS_EXTRA_SPACE = "0"
IMAGE_ROOTFS_MAXSIZE = "${IMAGE_ROOTFS_SIZE}"

# Generated resinhup-tar based on RESINHUP variable
IMAGE_FSTYPES = "${@bb.utils.contains('RESINHUP', 'yes', 'tar', '', d)}"

inherit core-image image-resin distro_features_check

IMAGE_FEATURES_append = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'development-image', 'debug-tweaks', '', d)} \
    splash \
    ssh-server-openssh \
    read-only-rootfs \
    "

IMAGE_INSTALL = " \
    packagegroup-core-boot \
    ${CORE_IMAGE_EXTRA_INSTALL} \
    packagegroup-resin-debugtools \
    packagegroup-resin-connectivity \
    packagegroup-resin \
    "

generate_rootfs_fingerprints () {
    # Generate fingerprints file for root filesystem
    # We exclude some entries that are bind mounted to state partition
    # and modified at runtime.
    find ${IMAGE_ROOTFS} -xdev -type f \
        -not -name ${RESIN_FINGERPRINT_FILENAME}.${RESIN_FINGERPRINT_EXT} \
        -not -name hostname \
        -not -name machine-id \
        -not -name .rnd \
        -exec md5sum {} \; | sed "s#${IMAGE_ROOTFS}##g" | \
        sort -k2 > ${IMAGE_ROOTFS}/${RESIN_FINGERPRINT_FILENAME}.${RESIN_FINGERPRINT_EXT}
}

generate_hostos_version () {
    echo "${HOSTOS_VERSION}" > ${DEPLOY_DIR_IMAGE}/VERSION_HOSTOS
}

DEPENDS += "jq-native"

IMAGE_PREPROCESS_COMMAND_append = " generate_rootfs_fingerprints ; "
IMAGE_POSTPROCESS_COMMAND += " generate_hostos_version ; "

RESIN_BOOT_PARTITION_FILES_append = " \
    resin-logo.png:/splash/resin-logo.png \
    os-release:/os-release \
"

# add the generated <machine-name>.json to the resin-boot partition, renamed as device-type.json
RESIN_BOOT_PARTITION_FILES_append = " ${RESIN_COREBASE}/../../../${MACHINE}.json:/device-type.json"

# example NetworkManager config file
RESIN_BOOT_PARTITION_FILES_append = " \
    system-connections/resin-sample.ignore:/system-connections/resin-sample.ignore \
    system-connections/README.ignore:/system-connections/README.ignore \
    "

# Resin image flag file
RESIN_BOOT_PARTITION_FILES_append = " ${RESIN_IMAGE_FLAG_FILE}:/${RESIN_IMAGE_FLAG_FILE}"
