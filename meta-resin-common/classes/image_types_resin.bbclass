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
    else:
        d.setVar('RESIN_ROOT_FS', '${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.${RESIN_ROOT_FSTYPE}')
        d.setVar('RESIN_RAW_IMG', '${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.resinos-img')
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

# Resin UBIFS Volume Creation

# Partition labels
RESIN_BOOT_DIR ?= "${DEPLOY_DIR_IMAGE}/boot"
RESIN_CONF_DIR ?= "${DEPLOY_DIR_IMAGE}/conf"

multiubivol_mkfs () {
    local mkubifs_args="$1"
    local additional_mkubifs_args="$2"
    local additional_ubinize_args="$3"
    local name="$4"
    if [ -z "$5" ]; then
        local vname=""
    else
        local vname="_$5"
    fi

    echo \[${name}\] >> ubinize${vname}.cfg
    echo ${additional_ubinize_args} >> ubinize${vname}.cfg
    mkfs.ubifs ${additional_mkubifs_args} ${mkubifs_args}
}

multiubivol_ubinize() {
    if [ -z "$1" ]; then
        local vname=""
    else
        local vname="_$1"
    fi
    ubinize -o ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}${vname}.rootfs.ubi ${UBINIZE_ARGS} ubinize${vname}.cfg

    # Cleanup cfg file
    mv ubinize${vname}.cfg ${DEPLOY_DIR_IMAGE}/

    # Create own symlinks for 'named' volumes
    if [ -n "$vname" ]; then
        cd ${DEPLOY_DIR_IMAGE}
        if [ -e ${IMAGE_NAME}${vname}.rootfs.ubifs ]; then
            ln -sf ${IMAGE_NAME}${vname}.rootfs.ubifs \
               ${IMAGE_LINK_NAME}${vname}.ubifs
        fi
        if [ -e ${IMAGE_NAME}${vname}.rootfs.ubi ]; then
            ln -sf ${IMAGE_NAME}${vname}.rootfs.ubi \
               ${IMAGE_LINK_NAME}${vname}.ubi
        fi
        cd -
    fi
}

IMAGE_CMD_multiubivol () {

    echo "Checking for Existing DIRs"
    if [ -d "$RESIN_BOOT_DIR/" ]
    then
        rm -rf "${RESIN_BOOT_DIR}/"
    fi
    
    if [ -d "$RESIN_CONF_DIR/" ]; then
        rm -rf "${RESIN_CONF_DIR}/"
    fi

    if [ -d "$DEPLOY_DIR_IMAGE/images/" ]; then
        rm -rf "${DEPLOY_DIR_IMAGE}/images/"
    fi


    echo "Create Resin conf DIR"
    mkdir -p ${RESIN_CONF_DIR}
    touch ${RESIN_CONF_DIR}/README_-_DO_NOT_DELETE_FILES_IN_THIS_DIRECTORY.txt

    echo "Copying files in RESIN_BOOT_PARTITION_FILE"
    mkdir ${RESIN_BOOT_DIR}
    echo -n '' > ${WORKDIR}/${RESIN_BOOT_FS_LABEL}.${FINGERPRINT_EXT}
    for RESIN_BOOT_PARTITION_FILE in ${RESIN_BOOT_PARTITION_FILES}; do

    echo "Handling $RESIN_BOOT_PARTITION_FILE ."

    # Check for item format
    case $RESIN_BOOT_PARTITION_FILE in
        *:*) ;;
        *) bbfatal "Some items in RESIN_BOOT_PARTITION_FILES ($RESIN_BOOT_PARTITION_FILE) are not in the 'src:dst' format."
    esac

    # Compute src and dst
    src="$(echo ${RESIN_BOOT_PARTITION_FILE} | awk -F: '{print $1}')"
    dst="$(echo ${RESIN_BOOT_PARTITION_FILE} | awk -F: '{print $2}')"
    if [ -z "${dst}" ]; then
        dst="/${src}" # dst was omitted
    fi
    src="${DEPLOY_DIR_IMAGE}/$src" # src is relative to deploy dir

    # Check that dst is an absolute path and assess if it should be a directory
    case $dst in
        /*)
            # Check if dst is a directory. Directory path ends with '/'.
            case $dst in
                */) dst_is_dir=true ;;
                *) dst_is_dir=false ;;
            esac
            ;;
        *) bbfatal "$dst in RESIN_BOOT_PARTITION_FILES is not an absolute path."
    esac

    # Check src type and existence
    if [ -d "$src" ]; then
        if ! $dst_is_dir; then
            bbfatal "You can't copy a directory to a file. You requested to copy $src in $dst."
        fi
        sources="$(find $src -maxdepth 1 -type f)"
    elif [ -f "$src" ]; then
        sources="$src"
    else
        bbfatal "$src is an invalid path referenced in RESIN_BOOT_PARTITION_FILES."
    fi

    # Normalize paths
    dst=$(realpath -ms $dst)
    if $dst_is_dir && [ ! "$dst" = "/" ]; then
        dst="$dst/" # realpath removes last '/' which we need to instruct mcopy that destination is a directory
    fi
    src=$(realpath -m $src)
    
    for src in $sources; do
        echo "Copying $src -> $dst ..."
        # Create the directories parent directories in dst
        directory="${RESIN_BOOT_DIR}"
        for path_segment in $(echo ${dst} | sed 's|/|\n|g' | head -n -1); do
            if [ -z "$path_segment" ]; then
                continue
            fi
            directory=$directory/$path_segment
            mkdir $directory || true
        done
        cp -r ${src} ${RESIN_BOOT_DIR}/${dst}
        if $dst_is_dir; then
            md5sum ${src} | awk -v awkdst="$dst$(basename $src)" '{ $2=awkdst; print }' >> ${WORKDIR}/${RESIN_BOOT_FS_LABEL}.${FINGERPRINT_EXT}
        else
            md5sum ${src} | awk -v awkdst="$dst" '{ $2=awkdst; print }' >> ${WORKDIR}/${RESIN_BOOT_FS_LABEL}.${FINGERPRINT_EXT}
        fi
    done
    done
    # Add stamp file
    echo "${IMAGE_NAME}-${IMAGEDATESTAMP}" > ${WORKDIR}/image-version-info
    cp ${WORKDIR}/image-version-info ${RESIN_BOOT_DIR}
    md5sum ${WORKDIR}/image-version-info | awk -v filepath="/image-version-info" '{ $2=filepath; print }' >> ${WORKDIR}/${RESIN_BOOT_FS_LABEL}.${FINGERPRINT_EXT}
    # Finally add the fingerprint to boot
    cp ${WORKDIR}/${RESIN_BOOT_FS_LABEL}.${FINGERPRINT_EXT} ${RESIN_BOOT_DIR}

    init_config_json ${WORKDIR}

    cp ${WORKDIR}/config.json ${RESIN_BOOT_DIR}/config.json.init

    # Split MKUBIFS_ARGS_<name> and UBINIZE_ARGS_<name>
    for name in ${UBIMULTIVOL_BUILD}; do
        eval local mkubifs_args=\"\$MKUBIFS_ARGS_${name}\"
        eval local additional_ubinize_args=\"\$ADDITIONAL_UBINIZE_ARGS_${name}\"
        eval local additional_mkubifs_args=\"\$ADDITIONAL_MKUBIFS_ARGS_${name}\"

        multiubivol_mkfs "${mkubifs_args}" "${additional_mkubifs_args}" "${additional_ubinize_args}" "${name}" "${UBI_VOLNAME}"
    done
    multiubivol_ubinize ${UBI_VOLNAME}
}

IMAGE_DEPENDS_multiubivol = "mtd-utils-native"

# This variable is available to request which values are suitable for IMAGE_FSTYPES
IMAGE_TYPES = " \
    multiubivol \
"

# Make sure we regenerate images if we modify the files that go in the boot
# partition
do_rootfs[vardeps] += "RESIN_BOOT_PARTITION_FILES"
