inherit image_types

#
# Create a raw image that can by written onto a storage device using dd/etcher.
#
# BALENA_IMAGE_BOOTLOADER        - bootloader
# BALENA_BOOT_PARTITION_FILES    - list of items describing files to be deployed
#                                 on boot partition
#                               - items need to be in the 'src:dst' format
#                               - src needs to be relative to DEPLOY_DIR_IMAGE
#                               - dst needs to be an absolute path
#                               - if dst is ommited ('src:' format used),
#                                 absolute path of src will be used as dst
# BALENA_ROOT_FSTYPE             - rootfs image type to be used for integrating
#                                 in the final raw image
# BALENA_BOOT_SIZE               - size of boot partition in KiB
# BALENA_RAW_IMG_COMPRESSION     - define this to compress the final raw image
#                                 with gzip, xz or bzip2
# PARTITION_TABLE_TYPE          - defines partition table type to use: gpt or
#                                 msdos. Defaults to msdos
# DEVICE_SPECIFIC_SPACE         - total amount of extra space that a device needs
#                                 for its configuration
#
#
#
# Partition table:
#
#   +-------------------+
#   |                   |  ^
#   | Reserved          |  |BALENA_IMAGE_ALIGNMENT
#   |                   |  v
#   +-------------------+
#   |                   |  ^
#   | Boot partition    |  |BALENA_BOOT_SIZE
#   |                   |  v
#   +-------------------+
#   |                   |  ^
#   | Root partition A  |  |BALENA_ROOTA_SIZE
#   |                   |  v
#   +-------------------+
#   |                   |  ^
#   | Root partition B  |  |BALENA_ROOTB_SIZE
#   |                   |  v
#   +-------------------+
#   |-------------------|
#   ||                 ||  ^
#   || Reserved        ||  |BALENA_IMAGE_ALIGNMENT
#   ||                 ||  v
#   |-------------------|
#   ||                 ||  ^
#   || State partition ||  |BALENA_STATE_SIZE
#   ||                 ||  v
#   |-------------------|
#   ||                 ||  ^
#   || Reserved        ||  |BALENA_IMAGE_ALIGNMENT
#   ||                 ||  v
#   |-------------------|
#   ||                 ||  ^
#   || Data partition  ||  |BALENA_DATA_SIZE
#   ||                 ||  v
#   |-------------------|
#   +-------------------+
#

BALENA_ROOT_FSTYPE ?= "hostapp-ext4"

python() {
    # Check if we are running on a poky version which deploys to IMGDEPLOYDIR
    # instead of DEPLOY_DIR_IMAGE (poky morty introduced this change)
    if d.getVar('IMGDEPLOYDIR', True):
        d.setVar('BALENA_ROOT_FS', '${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.${BALENA_ROOT_FSTYPE}')
        d.setVar('BALENA_RAW_IMG', '${IMGDEPLOYDIR}/${IMAGE_NAME}.balenaos-img')
        d.setVar('BALENA_RAW_BMAP', '${IMGDEPLOYDIR}/${IMAGE_NAME}.bmap')
        d.setVar('BALENA_DOCKER_IMG', '${IMGDEPLOYDIR}/${IMAGE_NAME}.docker')
        d.setVar('BALENA_HOSTAPP_IMG', '${IMGDEPLOYDIR}/${IMAGE_NAME}.${BALENA_ROOT_FSTYPE}')
    else:
        d.setVar('BALENA_ROOT_FS', '${DEPLOY_DIR_IMAGE}/${IMAGE_LINK_NAME}.${BALENA_ROOT_FSTYPE}')
        d.setVar('BALENA_RAW_IMG', '${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.balenaos-img')
        d.setVar('BALENA_RAW_BMAP', '${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.bmap')
        d.setVar('BALENA_DOCKER_IMG', '${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.docker')
        d.setVar('BALENA_HOSTAPP_IMG', '${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.${BALENA_ROOT_FSTYPE}')

    d.setVar('BALENA_IMAGE_BOOTLOADER_DEPLOY_TASK', ' '.join(bootloader + ':do_populate_sysroot' for bootloader in d.getVar("BALENA_IMAGE_BOOTLOADER", True).split()))
}

def disk_aligned(d, rootfs_size):
    saved_rootfs_size = rootfs_size
    rfs_alignment = int(d.getVar("IMAGE_ROOTFS_ALIGNMENT"))
    rootfs_size += rfs_alignment - 1
    rootfs_size -= rootfs_size % rfs_alignment
    bb.debug(1, 'requested rootfs size %d, aligned %d' % (saved_rootfs_size, rootfs_size) )
    return rootfs_size

# The rootfs size is calculated by substracting from the maximum BalenaOS image
# 700 MiB size, the size  of all other partitions except the data partition,
# dividing by 2, and substracting filesystem metadata and reserved allocations
def balena_rootfs_size(d):
    boot_part_size = int(d.getVar("BALENA_BOOT_SIZE"))
    state_part_size = int(d.getVar("BALENA_STATE_SIZE"))
    balena_rootfs_size = int(((700 * 1024) - boot_part_size - state_part_size) / 2)
    return int(disk_aligned(d, balena_rootfs_size))

BALENA_BOOT_FS_LABEL ?= "resin-boot"
BALENA_ROOTA_FS_LABEL ?= "resin-rootA"
BALENA_ROOTB_FS_LABEL ?= "resin-rootB"
BALENA_STATE_FS_LABEL ?= "resin-state"
BALENA_DATA_FS_LABEL ?= "resin-data"

# By default boot partition is a fat16
BALENA_BOOT_FAT32 ?= "0"

# Sizes in KiB
BALENA_BOOT_SIZE ?= "40960"
BALENA_ROOTB_SIZE ?= ""
BALENA_STATE_SIZE ?= "20480"
BALENA_IMAGE_ALIGNMENT ?= "4096"
IMAGE_ROOTFS_ALIGNMENT = "${BALENA_IMAGE_ALIGNMENT}"
DEVICE_SPECIFIC_SPACE ?= "${BALENA_IMAGE_ALIGNMENT}"
DEVICE_SPECIFIC_BOOTFS_OPTS ?= ""

BALENA_BOOT_WORKDIR ?= "${WORKDIR}/${BALENA_BOOT_FS_LABEL}"

BALENA_BOOT_FINGERPRINT_PATH ?= "${WORKDIR}/${BALENA_FINGERPRINT_FILENAME}.${BALENA_FINGERPRINT_EXT}"
BALENA_IMAGE_BOOTLOADER ?= "virtual/bootloader"
BALENA_RAW_IMG_COMPRESSION ?= ""
BALENA_DATA_FS ?= "${DEPLOY_DIR_IMAGE}/${BALENA_DATA_FS_LABEL}.img"
BALENA_BOOT_FS = "${WORKDIR}/${BALENA_BOOT_FS_LABEL}.img"
BALENA_ROOTB_FS = "${WORKDIR}/${BALENA_ROOTB_FS_LABEL}.img"
BALENA_STATE_FS ?= "${WORKDIR}/${BALENA_STATE_FS_LABEL}.img"

# balenaos-img depends on the rootfs image
IMAGE_TYPEDEP:balenaos-img = "${BALENA_ROOT_FSTYPE}"
do_image_balenaos_img[depends] = " \
    coreutils-native:do_populate_sysroot \
    docker-disk:do_deploy \
    dosfstools-native:do_populate_sysroot \
    e2fsprogs-native:do_populate_sysroot \
    mtools-native:do_populate_sysroot \
    parted-native:do_populate_sysroot \
    bmaptool-native:do_populate_sysroot \
    virtual/kernel:do_deploy \
    ${BALENA_IMAGE_BOOTLOADER_DEPLOY_TASK} \
    "

do_image_balenaos_img[depends] += "${@ ' virtual/bootloader:do_deploy ' if (d.getVar('UBOOT_CONFIG') or d.getVar('UBOOT_MACHINE')) else ''}"

device_specific_configuration() {
    echo "No device specific configuration"
}

IMAGE_CMD:balenaos-img () {
    #
    # Partition size computation (aligned to BALENA_IMAGE_ALIGNMENT)
    #

    # resin-boot
    BALENA_BOOT_SIZE_ALIGNED=$(expr ${BALENA_BOOT_SIZE} \+ ${BALENA_IMAGE_ALIGNMENT} - 1)
    BALENA_BOOT_SIZE_ALIGNED=$(expr ${BALENA_BOOT_SIZE_ALIGNED} \- ${BALENA_BOOT_SIZE_ALIGNED} \% ${BALENA_IMAGE_ALIGNMENT})

    # resin-rootA
    BALENA_ROOTA_SIZE=$(du -Lbks ${BALENA_ROOT_FS} | awk '{print $1}')
    BALENA_ROOTA_SIZE_ALIGNED=$(expr ${BALENA_ROOTA_SIZE} \+ ${BALENA_IMAGE_ALIGNMENT} \- 1)
    BALENA_ROOTA_SIZE_ALIGNED=$(expr ${BALENA_ROOTA_SIZE_ALIGNED} \- ${BALENA_ROOTA_SIZE_ALIGNED} \% ${BALENA_IMAGE_ALIGNMENT})

    # resin-rootB
    if [ -n "${BALENA_ROOTB_SIZE}" ]; then
        BALENA_ROOTB_SIZE_ALIGNED=$(expr ${BALENA_ROOTB_SIZE} \+ ${BALENA_IMAGE_ALIGNMENT} \- 1)
        BALENA_ROOTB_SIZE_ALIGNED=$(expr ${BALENA_ROOTB_SIZE_ALIGNED} \- ${BALENA_ROOTB_SIZE_ALIGNED} \% ${BALENA_IMAGE_ALIGNMENT})
    else
        BALENA_ROOTB_SIZE_ALIGNED=${BALENA_ROOTA_SIZE_ALIGNED}
    fi

    # resin-state
    if [ -n "${BALENA_STATE_FS}" ]; then
        BALENA_STATE_SIZE_ALIGNED=$(expr ${BALENA_STATE_SIZE} \+ ${BALENA_IMAGE_ALIGNMENT} \- 1)
        BALENA_STATE_SIZE_ALIGNED=$(expr ${BALENA_STATE_SIZE_ALIGNED} \- ${BALENA_STATE_SIZE_ALIGNED} \% ${BALENA_IMAGE_ALIGNMENT})
    else
        BALENA_STATE_SIZE_ALIGNED=${BALENA_IMAGE_ALIGNMENT}
    fi

    # resin-data
    if [ -n "${BALENA_DATA_FS}" ]; then
        BALENA_DATA_SIZE=`du -bks ${BALENA_DATA_FS} | awk '{print $1}'`
        BALENA_DATA_SIZE_ALIGNED=$(expr ${BALENA_DATA_SIZE} \+ ${BALENA_IMAGE_ALIGNMENT} \- 1)
        BALENA_DATA_SIZE_ALIGNED=$(expr ${BALENA_DATA_SIZE_ALIGNED} \- ${BALENA_DATA_SIZE_ALIGNED} \% ${BALENA_IMAGE_ALIGNMENT})
    else
        BALENA_DATA_SIZE_ALIGNED=${BALENA_IMAGE_ALIGNMENT}
    fi

    if [ $(expr ${DEVICE_SPECIFIC_SPACE} % ${BALENA_IMAGE_ALIGNMENT}) -ne 0  ]; then
        bbfatal "The space reserved for your specific device is not aligned to ${BALENA_IMAGE_ALIGNMENT}."
    fi

    BALENA_RAW_IMG_SIZE=$(expr \
        ${DEVICE_SPECIFIC_SPACE} \+ \
        ${BALENA_IMAGE_ALIGNMENT} \+ \
        ${BALENA_BOOT_SIZE_ALIGNED} \+ \
        ${BALENA_ROOTA_SIZE_ALIGNED} \+ \
        ${BALENA_ROOTB_SIZE_ALIGNED} \+ \
        ${BALENA_IMAGE_ALIGNMENT} \+ \
        ${BALENA_STATE_SIZE_ALIGNED} \+ \
        ${BALENA_IMAGE_ALIGNMENT} \+ \
        ${BALENA_DATA_SIZE_ALIGNED} \
    )
    echo "Creating raw image as it follow:"
    echo "  Boot partition ${BALENA_BOOT_SIZE_ALIGNED} KiB [$(expr ${BALENA_BOOT_SIZE_ALIGNED} \/ 1024) MiB]"
    echo "  Root A partition ${BALENA_ROOTA_SIZE_ALIGNED} KiB [$(expr ${BALENA_ROOTA_SIZE_ALIGNED} \/ 1024) MiB]"
    echo "  Root B partition ${BALENA_ROOTA_SIZE_ALIGNED} KiB [$(expr ${BALENA_ROOTB_SIZE_ALIGNED} \/ 1024) MiB]"
    echo "  State partition ${BALENA_STATE_SIZE_ALIGNED} KiB [$(expr ${BALENA_STATE_SIZE_ALIGNED} \/ 1024) MiB]"
    echo "  Data partition ${BALENA_DATA_SIZE_ALIGNED} KiB [$(expr ${BALENA_DATA_SIZE_ALIGNED} \/ 1024) MiB]"
    echo "---"
    echo "Total raw image size ${BALENA_RAW_IMG_SIZE} KiB [$(expr ${BALENA_RAW_IMG_SIZE} \/ 1024) MiB]"

    #
    # Generate the raw image with partition table
    #

    truncate -s "$(expr ${BALENA_RAW_IMG_SIZE} \* 1024)" "${BALENA_RAW_IMG}"

    if [ "${PARTITION_TABLE_TYPE}" != "msdos" ] && [ "${PARTITION_TABLE_TYPE}" != "gpt" ]; then
        bbfatal "Unrecognized partition table: ${PARTITION_TABLE_TYPE}"
    fi

    parted ${BALENA_RAW_IMG} mklabel ${PARTITION_TABLE_TYPE}

    device_specific_configuration

    # resin-boot
    #
    if [ "${PARTITION_TABLE_TYPE}" = "msdos" ]; then
        if [ "${BALENA_BOOT_FAT32}" = "1" ]; then
            OPTS="primary fat32"
        else
            OPTS="primary fat16"
        fi
    elif [ "${PARTITION_TABLE_TYPE}" = "gpt" ]; then
        OPTS="${BALENA_BOOT_FS_LABEL}"
    fi
    START=${DEVICE_SPECIFIC_SPACE}
    END=$(expr ${START} \+ ${BALENA_BOOT_SIZE_ALIGNED})
    parted -s ${BALENA_RAW_IMG} unit KiB mkpart ${OPTS} ${START} ${END}
    BALENA_BOOT_PN=$(parted -s ${BALENA_RAW_IMG} print | tail -n 2 | tr '\n' ' ' | awk '{print $1}')
    parted -s ${BALENA_RAW_IMG} set ${BALENA_BOOT_PN} boot on

    # resin-rootA
    if [ "${PARTITION_TABLE_TYPE}" = "msdos" ]; then
        OPTS="primary"
    elif [ "${PARTITION_TABLE_TYPE}" = "gpt" ]; then
        OPTS="${BALENA_ROOTA_FS_LABEL}"
    fi
    START=${END}
    END=$(expr ${START} \+ ${BALENA_ROOTA_SIZE_ALIGNED})
    parted -s ${BALENA_RAW_IMG} unit KiB mkpart ${OPTS} ${START} ${END}

    # resin-rootB
    if [ "${PARTITION_TABLE_TYPE}" = "msdos" ]; then
        OPTS="primary"
    elif [ "${PARTITION_TABLE_TYPE}" = "gpt" ]; then
        OPTS="${BALENA_ROOTB_FS_LABEL}"
    fi
    START=${END}
    END=$(expr ${START} \+ ${BALENA_ROOTB_SIZE_ALIGNED})
    parted -s ${BALENA_RAW_IMG} unit KiB mkpart ${OPTS} ${START} ${END}
    BALENA_ROOTB_PN=$(parted -s ${BALENA_RAW_IMG} print | tail -n 2 | tr '\n' ' ' | awk '{print $1}')

    # extended partition
    if [ "${PARTITION_TABLE_TYPE}" = "msdos" ]; then
        START=${END}
        END=$(expr ${START} \+ ${BALENA_IMAGE_ALIGNMENT})
        parted -s ${BALENA_RAW_IMG} -- unit KiB mkpart extended ${START} -1s
    fi

    # resin-state
    if [ "${PARTITION_TABLE_TYPE}" = "msdos" ]; then
        OPTS="logical"
    elif [ "${PARTITION_TABLE_TYPE}" = "gpt" ]; then
        OPTS="${BALENA_STATE_FS_LABEL}"
    fi
    START=${END}
    END=$(expr ${START} \+ ${BALENA_STATE_SIZE_ALIGNED})
    parted -s ${BALENA_RAW_IMG} unit KiB mkpart ${OPTS} ${START} ${END}
    BALENA_STATE_PN=$(parted -s ${BALENA_RAW_IMG} print | tail -n 2 | tr '\n' ' ' | awk '{print $1}')

    # resin-data
    if [ "${PARTITION_TABLE_TYPE}" = "msdos" ]; then
        OPTS="logical"
        START=$(expr ${END} \+ ${BALENA_IMAGE_ALIGNMENT})
    elif [ "${PARTITION_TABLE_TYPE}" = "gpt" ]; then
        OPTS="${BALENA_DATA_FS_LABEL}"
        START=${END}
    fi
    parted -s ${BALENA_RAW_IMG} -- unit KiB mkpart ${OPTS} ${START} 100%

    #
    # Generate partitions
    #

    # resin-boot
    BALENA_BOOT_BLOCKS=$(LC_ALL=C parted -s ${BALENA_RAW_IMG} unit b print | grep -E "^(| )${BALENA_BOOT_PN} " | awk '{ print substr($4, 1, length($4 -1)) / 512 /2 }')
    rm -rf ${BALENA_BOOT_FS}
    OPTS="-n ${BALENA_BOOT_FS_LABEL} -S 512 -C"
    if [ "${BALENA_BOOT_FAT32}" = "1" ]; then
        OPTS="$OPTS -F 32"
    fi
    OPTS="$OPTS ${DEVICE_SPECIFIC_BOOTFS_OPTS}"
    eval mkfs.vfat "$OPTS" "${BALENA_BOOT_FS}" "${BALENA_BOOT_BLOCKS}"
    if [ "$(ls -A ${BALENA_BOOT_WORKDIR})" ]; then
        mcopy -i ${BALENA_BOOT_FS} -svm ${BALENA_BOOT_WORKDIR}/* ::
    else
        bbwarn "Boot partition was detected empty."
    fi

    # resin-rootB
    BALENA_ROOTB_BLOCKS=$(LC_ALL=C parted -s ${BALENA_RAW_IMG} unit b print | grep -E "^(| )${BALENA_ROOTB_PN} " | awk '{ print substr($4, 1, length($4 -1)) / 512 /2 }')
    rm -rf ${BALENA_ROOTB_FS}
    truncate -s "$(expr ${BALENA_ROOTB_BLOCKS} \* 1024 )" "${BALENA_ROOTB_FS}"
    mkfs.ext4 -E lazy_itable_init=0,lazy_journal_init=0 -i 8192 -F -L "${BALENA_ROOTB_FS_LABEL}" ${BALENA_ROOTB_FS}

    # resin-state
    if [ -n "${BALENA_STATE_FS}" ]; then
        BALENA_STATE_BLOCKS=$(LC_ALL=C parted -s ${BALENA_RAW_IMG} unit b print | grep -E "^(| )${BALENA_STATE_PN} " | awk '{ print substr($4, 1, length($4 -1)) / 512 /2 }')
        rm -rf ${BALENA_STATE_FS}
        truncate -s "$(expr ${BALENA_STATE_BLOCKS} \* 1024 )" "${BALENA_STATE_FS}"
        mkfs.ext4 -F -L "${BALENA_STATE_FS_LABEL}" ${BALENA_STATE_FS}
    fi

    # Label what is not labeled
    if case "${BALENA_ROOT_FSTYPE}" in *ext4) true;; *) false;; esac; then # can be ext4 or hostapp-ext4
        e2label ${BALENA_ROOT_FS} ${BALENA_ROOTA_FS_LABEL}
    else
        bbfatal "Rootfs labeling for type '${BALENA_ROOT_FSTYPE}' has not been implemented!"
    fi

    if [ -n "${BALENA_DATA_FS}" ]; then
        e2label ${BALENA_DATA_FS} ${BALENA_DATA_FS_LABEL}
    fi

    #
    # Burn partitions
    #
    offset=${DEVICE_SPECIFIC_SPACE}
    dd if=${BALENA_BOOT_FS} of=${BALENA_RAW_IMG} conv=notrunc,sparse seek=${offset} bs=1024
    offset=$(expr ${offset} \+ ${BALENA_BOOT_SIZE_ALIGNED})
    dd if=${BALENA_ROOT_FS} of=${BALENA_RAW_IMG} conv=notrunc,sparse seek=${offset} bs=1024
    offset=$(expr ${offset} \+ ${BALENA_ROOTA_SIZE_ALIGNED})
    dd if=${BALENA_ROOTB_FS} of=${BALENA_RAW_IMG} conv=notrunc,sparse seek=${offset} bs=1024
    offset=$(expr ${offset} \+ ${BALENA_ROOTB_SIZE_ALIGNED})
    if [ -n "${BALENA_STATE_FS}" ]; then
        if [ "${PARTITION_TABLE_TYPE}" = "msdos" ]; then
            offset=$(expr ${offset} \+ ${BALENA_IMAGE_ALIGNMENT})
            dd if=${BALENA_STATE_FS} of=${BALENA_RAW_IMG} conv=notrunc,sparse seek=${offset} bs=1024
        elif [ "${PARTITION_TABLE_TYPE}" = "gpt" ]; then
            dd if=${BALENA_STATE_FS} of=${BALENA_RAW_IMG} conv=notrunc,sparse seek=${offset} bs=1024
        fi
    fi
    if [ -n "${BALENA_DATA_FS}" ]; then
        if [ "${PARTITION_TABLE_TYPE}" = "msdos" ]; then
            offset=$(expr ${offset} \+ ${BALENA_STATE_SIZE_ALIGNED} \+ ${BALENA_IMAGE_ALIGNMENT})
            dd if=${BALENA_DATA_FS} of=${BALENA_RAW_IMG} conv=notrunc,sparse seek=${offset} bs=1024
        elif [ "${PARTITION_TABLE_TYPE}" = "gpt" ]; then
            offset=$(expr ${offset} \+ ${BALENA_STATE_SIZE_ALIGNED})
            dd if=${BALENA_DATA_FS} of=${BALENA_RAW_IMG} conv=notrunc,sparse seek=${offset} bs=1024
        fi
    fi

    # create bmap to enable recreating sparse image after full allocation
    bmaptool create ${BALENA_RAW_IMG} > ${BALENA_RAW_BMAP}

    # Optionally apply compression
    case "${BALENA_RAW_IMG_COMPRESSION}" in
    "gzip")
        gzip -k9 "${BALENA_RAW_IMG}"
        ;;
    "bzip2")
        bzip2 -k9 "${BALENA_RAW_IMG}"
        ;;
    "xz")
        xz -k "${BALENA_RAW_IMG}"
        ;;
    esac
}

# Make sure we regenerate images if we modify the files that go in the boot
# partition
do_rootfs[vardeps] += "BALENA_BOOT_PARTITION_FILES"

# XXX(petrosagg): This should be eventually implemented using a docker-native daemon
IMAGE_CMD:docker () {
    DOCKER_IMAGE=$(${IMAGE_CMD_TAR} -cv -C ${IMAGE_ROOTFS} . | DOCKER_API_VERSION=${BALENA_API_VERSION} docker import -)
    DOCKER_API_VERSION=${BALENA_API_VERSION} docker save ${DOCKER_IMAGE} > ${BALENA_DOCKER_IMG}
}

IMAGE_TYPEDEP:hostapp-ext4 = "docker"

do_image_hostapp_ext4[depends] = " \
    mkfs-hostapp-native:do_populate_sysroot \
    "

IMAGE_CMD:hostapp-ext4 () {
    truncate -s "$(expr ${ROOTFS_SIZE} \* 1024)" "${BALENA_HOSTAPP_IMG}"
    mkfs.hostapp -t "${TMPDIR}" -s "${STAGING_DIR_NATIVE}" -i ${BALENA_DOCKER_IMG} -o ${BALENA_HOSTAPP_IMG}
}

IMAGE_TYPEDEP:balenaos-img.sig = "balenaos-img"

IMAGE_CMD:balenaos-img.sig () {
    if [ "x${SIGN_API}" = "x" ]; then
        bbnote "Signing API not defined"
        return 0
    fi
    if [ "x${SIGN_API_KEY}" = "x" ]; then
        bbfatal "Signing API key must be defined"
    fi

    for SIGNING_ARTIFACT in ${SIGNING_ARTIFACTS}
    do
        if [ -z "${SIGNING_ARTIFACT}" ] || [ ! -f "${SIGNING_ARTIFACT}" ]; then
            bbfatal "Nothing to sign"
        fi

        DIGEST=$(openssl dgst -hex -sha256 "${SIGNING_ARTIFACT}" | awk '{print $2}')

        REQUEST_FILE=$(mktemp)
        RESPONSE_FILE=$(mktemp)
        echo "{\"cert_id\": \"${SIGN_KMOD_KEY_ID}\", \"digest\": \"${DIGEST}\"}" > "${REQUEST_FILE}"
        CURL_CA_BUNDLE="${STAGING_DIR_NATIVE}/etc/ssl/certs/ca-certificates.crt" curl --retry 5 --fail --silent "${SIGN_API}/cert/sign" -X POST -H "Content-Type: application/json" -H "X-API-Key: ${SIGN_API_KEY}" -d "@${REQUEST_FILE}" > "${RESPONSE_FILE}"
        jq -r ".signature" < "${RESPONSE_FILE}" | base64 -d > "${SIGNING_ARTIFACT}.sig"
        rm -f "${REQUEST_FILE}" "${RESPONSE_FILE}"
    done
}

do_image_balenaos_img_sig[network] = "1"
do_image_balenaos_img_sig[depends] += " \
    openssl-native:do_populate_sysroot \
    curl-native:do_populate_sysroot \
    jq-native:do_populate_sysroot \
    ca-certificates-native:do_populate_sysroot \
    coreutils-native:do_populate_sysroot \
    gnupg-native:do_populate_sysroot \
    "

do_image_balenaos_img_sig[vardeps] += " \
    SIGN_API \
    SIGN_KMOD_KEY_ID \
    "
