inherit image_types

#
# Create a raw image that can by written onto a storage device using dd/etcher.
#
# RESIN_IMAGE_BOOTLOADER        - bootloader
# RESIN_BOOT_PARTITION_FILES    - list of items describing files to be deployed
#                                 on boot partition
#                               - items need to be in the 'src:dst' format
#                               - src needs to be relative to DEPLOY_DIR_IMAGE
#                               - dst needs to be an absolute path
#                               - if dst is ommited ('src:' format used),
#                                 absolute path of src will be used as dst
# RESIN_ROOT_FSTYPE             - rootfs image type to be used for integrating
#                                 in the final raw image
# RESIN_BOOT_SIZE               - size of boot partition in KiB
# RESIN_RAW_IMG_COMPRESSION     - define this to compress the final raw image
#                                 with gzip, xz or bzip2
#
# Partition table:
#
#   +-------------------+
#   |                   |  ^
#   | Reserved          |  |RESIN_IMAGE_ALIGNMENT
#   |                   |  v
#   +-------------------+
#   |                   |  ^
#   | Boot partition    |  |RESIN_BOOT_SIZE
#   |                   |  v
#   +-------------------+
#   |                   |  ^
#   | Root partition A  |  |RESIN_ROOTA_SIZE
#   |                   |  v
#   +-------------------+
#   |                   |  ^
#   | Root partition B  |  |RESIN_ROOTB_SIZE
#   |                   |  v
#   +-------------------+
#   |-------------------|
#   ||                 ||  ^
#   || Reserved        ||  |RESIN_IMAGE_ALIGNMENT
#   ||                 ||  v
#   |-------------------|
#   ||                 ||  ^
#   || State partition ||  |RESIN_STATE_SIZE
#   ||                 ||  v
#   |-------------------|
#   ||                 ||  ^
#   || Reserved        ||  |RESIN_IMAGE_ALIGNMENT
#   ||                 ||  v
#   |-------------------|
#   ||                 ||  ^
#   || Data partition  ||  |RESIN_DATA_SIZE
#   ||                 ||  v
#   |-------------------|
#   +-------------------+
#

RESIN_ROOT_FSTYPE ?= "ext4"

python() {
    # Check if we are running on a poky version which deploys to IMGDEPLOYDIR
    # instead of DEPLOY_DIR_IMAGE (poky morty introduced this change)
    if d.getVar('IMGDEPLOYDIR', True):
        d.setVar('RESIN_ROOT_FS', '${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.${RESIN_ROOT_FSTYPE}')
        d.setVar('RESIN_RAW_IMG', '${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.resinos-img')
        d.setVar('RESIN_DOCKER_IMG', '${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.docker')
    else:
        d.setVar('RESIN_ROOT_FS', '${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.${RESIN_ROOT_FSTYPE}')
        d.setVar('RESIN_RAW_IMG', '${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.resinos-img')
        d.setVar('RESIN_DOCKER_IMG', '${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.docker')
}


RESIN_BOOT_FS_LABEL ?= "resin-boot"
RESIN_ROOTA_FS_LABEL ?= "resin-rootA"
RESIN_ROOTB_FS_LABEL ?= "resin-rootB"
RESIN_STATE_FS_LABEL ?= "resin-state"
RESIN_DATA_FS_LABEL ?= "resin-data"

# Sizes in KiB
RESIN_BOOT_SIZE ?= "40960"
RESIN_ROOTB_SIZE ?= ""
RESIN_STATE_SIZE ?= "20480"
RESIN_IMAGE_ALIGNMENT ?= "4096"
IMAGE_ROOTFS_ALIGNMENT = "${RESIN_IMAGE_ALIGNMENT}"

RESIN_BOOT_WORKDIR ?= "${WORKDIR}/${RESIN_BOOT_FS_LABEL}"

RESIN_FINGERPRINT_EXT ?= "fingerprint"
RESIN_FINGERPRINT_FILENAME ?= "resinos"
RESIN_BOOT_FINGERPRINT_PATH ?= "${WORKDIR}/${RESIN_FINGERPRINT_FILENAME}.${RESIN_FINGERPRINT_EXT}"
RESIN_IMAGE_BOOTLOADER ?= "virtual/bootloader"
RESIN_RAW_IMG_COMPRESSION ?= ""
RESIN_DATA_FS ?= "${DEPLOY_DIR}/images/${MACHINE}/${RESIN_DATA_FS_LABEL}.img"
RESIN_BOOT_FS = "${WORKDIR}/${RESIN_BOOT_FS_LABEL}.img"
RESIN_STATE_FS ?= "${WORKDIR}/${RESIN_STATE_FS_LABEL}.img"

# resinos-img depends on the rootfs image
IMAGE_TYPEDEP_resinos-img = "${RESIN_ROOT_FSTYPE}"
IMAGE_DEPENDS_resinos-img = " \
    coreutils-native \
    docker-disk \
    dosfstools-native \
    e2fsprogs-native \
    mtools-native \
    parted-native \
    virtual/kernel \
    ${RESIN_IMAGE_BOOTLOADER} \
    "

IMAGE_CMD_resinos-img () {
    #
    # Partition size computation (aligned to RESIN_IMAGE_ALIGNMENT)
    #

    # resin-boot
    RESIN_BOOT_SIZE_ALIGNED=$(expr ${RESIN_BOOT_SIZE} \+ ${RESIN_IMAGE_ALIGNMENT} - 1)
    RESIN_BOOT_SIZE_ALIGNED=$(expr ${RESIN_BOOT_SIZE_ALIGNED} \- ${RESIN_BOOT_SIZE_ALIGNED} \% ${RESIN_IMAGE_ALIGNMENT})

    # resin-rootA
    RESIN_ROOTA_SIZE=$(du -bks ${RESIN_ROOT_FS} | awk '{print $1}')
    RESIN_ROOTA_SIZE_ALIGNED=$(expr ${RESIN_ROOTA_SIZE} \+ ${RESIN_IMAGE_ALIGNMENT} \- 1)
    RESIN_ROOTA_SIZE_ALIGNED=$(expr ${RESIN_ROOTA_SIZE_ALIGNED} \- ${RESIN_ROOTA_SIZE_ALIGNED} \% ${RESIN_IMAGE_ALIGNMENT})

    # resin-rootB
    if [ -n "${RESIN_ROOTB_SIZE}" ]; then
        RESIN_ROOTB_SIZE_ALIGNED=$(expr ${RESIN_ROOTB_SIZE} \+ ${RESIN_IMAGE_ALIGNMENT} \- 1)
        RESIN_ROOTB_SIZE_ALIGNED=$(expr ${RESIN_ROOTB_SIZE_ALIGNED} \- ${RESIN_ROOTB_SIZE_ALIGNED} \% ${RESIN_IMAGE_ALIGNMENT})
    else
        RESIN_ROOTB_SIZE_ALIGNED=${RESIN_ROOTA_SIZE_ALIGNED}
    fi

    # resin-state
    if [ -n "${RESIN_STATE_FS}" ]; then
        RESIN_STATE_SIZE_ALIGNED=$(expr ${RESIN_STATE_SIZE} \+ ${RESIN_IMAGE_ALIGNMENT} \- 1)
        RESIN_STATE_SIZE_ALIGNED=$(expr ${RESIN_STATE_SIZE_ALIGNED} \- ${RESIN_STATE_SIZE_ALIGNED} \% ${RESIN_IMAGE_ALIGNMENT})
    else
        RESIN_STATE_SIZE_ALIGNED=${RESIN_IMAGE_ALIGNMENT}
    fi

    # resin-data
    if [ -n "${RESIN_DATA_FS}" ]; then
        RESIN_DATA_SIZE=`du -bks ${RESIN_DATA_FS} | awk '{print $1}'`
        RESIN_DATA_SIZE_ALIGNED=$(expr ${RESIN_DATA_SIZE} \+ ${RESIN_IMAGE_ALIGNMENT} \- 1)
        RESIN_DATA_SIZE_ALIGNED=$(expr ${RESIN_DATA_SIZE_ALIGNED} \- ${RESIN_DATA_SIZE_ALIGNED} \% ${RESIN_IMAGE_ALIGNMENT})
    else
        RESIN_DATA_SIZE_ALIGNED=${RESIN_IMAGE_ALIGNMENT}
    fi

    RESIN_RAW_IMG_SIZE=$(expr \
        ${RESIN_IMAGE_ALIGNMENT} \+ \
        ${RESIN_BOOT_SIZE_ALIGNED} \+ \
        ${RESIN_ROOTA_SIZE_ALIGNED} \+ \
        ${RESIN_ROOTB_SIZE_ALIGNED} \+ \
        ${RESIN_IMAGE_ALIGNMENT} \+ \
        ${RESIN_STATE_SIZE_ALIGNED} \+ \
        ${RESIN_IMAGE_ALIGNMENT} \+ \
        ${RESIN_DATA_SIZE_ALIGNED} \
    )
    echo "Creating raw image as it follow:"
    echo "  Boot partition ${RESIN_BOOT_SIZE_ALIGNED} KiB [$(expr ${RESIN_BOOT_SIZE_ALIGNED} \/ 1024) MiB]"
    echo "  Root A partition ${RESIN_ROOTA_SIZE_ALIGNED} KiB [$(expr ${RESIN_ROOTA_SIZE_ALIGNED} \/ 1024) MiB]"
    echo "  Root B partition ${RESIN_ROOTA_SIZE_ALIGNED} KiB [$(expr ${RESIN_ROOTB_SIZE_ALIGNED} \/ 1024) MiB]"
    echo "  State partition ${RESIN_STATE_SIZE_ALIGNED} KiB [$(expr ${RESIN_STATE_SIZE_ALIGNED} \/ 1024) MiB]"
    echo "  Data partition ${RESIN_DATA_SIZE_ALIGNED} KiB [$(expr ${RESIN_DATA_SIZE_ALIGNED} \/ 1024) MiB]"
    echo "---"
    echo "Total raw image size ${RESIN_RAW_IMG_SIZE} KiB [$(expr ${RESIN_RAW_IMG_SIZE} \/ 1024) MiB]"

    #
    # Generate the raw image with partition table
    #

    dd if=/dev/zero of=${RESIN_RAW_IMG} bs=1024 count=0 seek=${RESIN_RAW_IMG_SIZE}
    parted -s ${RESIN_RAW_IMG} mklabel msdos

    # resin-boot
    START=${RESIN_IMAGE_ALIGNMENT}
    END=$(expr ${START} \+ ${RESIN_BOOT_SIZE_ALIGNED})
    parted -s ${RESIN_RAW_IMG} unit KiB mkpart primary fat16 ${START} ${END}
    parted -s ${RESIN_RAW_IMG} set 1 boot on

    # resin-rootA
    START=${END}
    END=$(expr ${START} \+ ${RESIN_ROOTA_SIZE_ALIGNED})
    parted -s ${RESIN_RAW_IMG} unit KiB mkpart primary ext4 ${START} ${END}

    # resin-rootB
    START=${END}
    END=$(expr ${START} \+ ${RESIN_ROOTB_SIZE_ALIGNED})
    parted -s ${RESIN_RAW_IMG} unit KiB mkpart primary ext4 ${START} ${END}

    # extended partition
    START=${END}
    parted -s ${RESIN_RAW_IMG} -- unit KiB mkpart extended ${START} -1s

    # resin-state
    START=$(expr ${START} \+ ${RESIN_IMAGE_ALIGNMENT})
    END=$(expr ${START} \+ ${RESIN_STATE_SIZE_ALIGNED})
    parted -s ${RESIN_RAW_IMG} unit KiB mkpart logical ext4 ${START} ${END}

    # resin-data
    START=$(expr ${END} \+ ${RESIN_IMAGE_ALIGNMENT})
    parted -s ${RESIN_RAW_IMG} -- unit KiB mkpart logical ext4 ${START} -1s

    #
    # Generate partitions
    #

    # resin-boot
    RESIN_BOOT_BLOCKS=$(LC_ALL=C parted -s ${RESIN_RAW_IMG} unit b print | awk '/ 1 / { print substr($4, 1, length($4 -1)) / 512 /2 }')
    rm -rf ${RESIN_BOOT_FS}
    mkfs.vfat -n "${RESIN_BOOT_FS_LABEL}" -S 512 -C ${RESIN_BOOT_FS} $RESIN_BOOT_BLOCKS
    if [ "$(ls -A ${RESIN_BOOT_WORKDIR})" ]; then
        mcopy -i ${RESIN_BOOT_FS} -sv ${RESIN_BOOT_WORKDIR}/* ::
    else
        bbwarn "Boot partition was detected empty."
    fi

    # resin-state
    if [ -n "${RESIN_STATE_FS}" ]; then
        RESIN_STATE_BLOCKS=$(LC_ALL=C parted -s ${RESIN_RAW_IMG} unit b print | awk '/ 5 / { print substr($4, 1, length($4 -1)) / 512 /2 }')
        rm -rf ${RESIN_STATE_FS}
        dd if=/dev/zero of=${RESIN_STATE_FS} count=${RESIN_STATE_BLOCKS} bs=1024
        mkfs.ext4 -F -L "${RESIN_STATE_FS_LABEL}" ${RESIN_STATE_FS}
    fi

    # Label what is not labeled
    e2label ${RESIN_ROOT_FS} ${RESIN_ROOTA_FS_LABEL}
    if [ -n "${RESIN_DATA_FS}" ]; then
        e2label ${RESIN_DATA_FS} ${RESIN_DATA_FS_LABEL}
    fi

    #
    # Burn partitions
    #
    dd if=${RESIN_BOOT_FS} of=${RESIN_RAW_IMG} conv=notrunc,fsync seek=1 bs=$(expr 1024 \* ${RESIN_IMAGE_ALIGNMENT})
    dd if=${RESIN_ROOT_FS} of=${RESIN_RAW_IMG} conv=notrunc,fsync seek=1 bs=$(expr 1024 \* $(expr ${RESIN_IMAGE_ALIGNMENT} \+ ${RESIN_BOOT_SIZE_ALIGNED}))
    if [ -n "${RESIN_STATE_FS}" ]; then
        dd if=${RESIN_STATE_FS} of=${RESIN_RAW_IMG} conv=notrunc,fsync seek=1 bs=$(expr 1024 \* $(expr ${RESIN_IMAGE_ALIGNMENT} \+ ${RESIN_BOOT_SIZE_ALIGNED} \+ ${RESIN_ROOTA_SIZE_ALIGNED} \+ ${RESIN_ROOTB_SIZE_ALIGNED} \+ ${RESIN_IMAGE_ALIGNMENT}))
    fi
    if [ -n "${RESIN_DATA_FS}" ]; then
        dd if=${RESIN_DATA_FS} of=${RESIN_RAW_IMG} conv=notrunc,fsync seek=1 bs=$(expr 1024 \* $(expr ${RESIN_IMAGE_ALIGNMENT} \+ ${RESIN_BOOT_SIZE_ALIGNED} \+ ${RESIN_ROOTA_SIZE_ALIGNED} \+ ${RESIN_ROOTB_SIZE_ALIGNED} \+ ${RESIN_IMAGE_ALIGNMENT} \+ ${RESIN_STATE_SIZE_ALIGNED} \+ ${RESIN_IMAGE_ALIGNMENT}))
    fi

    # Optionally apply compression
    case "${RESIN_RAW_IMG_COMPRESSION}" in
    "gzip")
        gzip -k9 "${RESIN_RAW_IMG}"
        ;;
    "bzip2")
        bzip2 -k9 "${RESIN_RAW_IMG}"
        ;;
    "xz")
        xz -k "${RESIN_RAW_IMG}"
        ;;
    esac
}

# Make sure we regenerate images if we modify the files that go in the boot
# partition
do_rootfs[vardeps] += "RESIN_BOOT_PARTITION_FILES"

# XXX(petrosagg): This should be eventually implemented using a docker-native daemon
IMAGE_CMD_docker () {
    DOCKER_IMAGE=$(${IMAGE_CMD_TAR} -cv -C ${IMAGE_ROOTFS} . | DOCKER_API_VERSION=1.22 docker import -)
    DOCKER_API_VERSION=1.22 docker save ${DOCKER_IMAGE} > ${RESIN_DOCKER_IMG}
}
