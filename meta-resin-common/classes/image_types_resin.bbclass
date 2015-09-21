inherit image_types

# Images inheriting this class MUST define:
# RESIN_IMAGE_BOOTLOADER 	- bootloader
# RESIN_BOOT_PARTITION_FILES 	- this is a list of files relative to DEPLOY_DIR_IMAGE that will be included in the vfat partition
#				- should be a list of elements of the following format "FilenameRelativeToDeployDir:FilenameOnTheTarget"
#				- if FilenameOnTheTarget is omitted the same filename will be used
#
# Optional:
# RESIN_SDIMG_ROOTFS_TYPE 	- rootfs image to be used [default: ext3]
# RESIN_BOOT_SPACE		- size of boot partition in KiB [default: 40960]
# RESIN_SDIMG_COMPRESSION	- define this to compress the final SD image with gzip, xz or bzip2 [default: empty]

#
# Create an image that can by written onto a SD card using dd.
#
# The disk layout used is:
#
#    0                      -> IMAGE_ROOTFS_ALIGNMENT         - reserved for other data
#    IMAGE_ROOTFS_ALIGNMENT -> RESIN_BOOT_SPACE               - boot partition (usually kernel and bootloaders)
#    RESIN_BOOT_SPACE       -> ROOTFS_SIZE                    - rootfs
#    ROOTFS_SIZE            -> UPDATE_SIZE                    - update partition (this is a duplicate of rootfs so UPDATE_SIZE == ROOTFS_SIZE)
#    UPDATE_SIZE            -> SDIMG_SIZE                     - extended partition
#
# The exended partition layout is:
#    0                      -> IMAGE_ROOTFS_ALIGNMENT         - reserved for other data
#    IMAGE_ROOTFS_ALIGNMENT -> CONFIG_SIZE                    - the config.json gets injected in here
#    CONFIG_SIZE            -> IMAGE_ROOTFS_ALIGNMENT         - reserved for other data
#    IMAGE_ROOTFS_ALIGNMENT -> SDIMG_SIZE                     - btrfs partition

#
#            4MiB                  40MiB          ROOTFS_SIZE       ROOTFS_SIZE              4MiB                16MiB                4MiB                4MiB
# <-----------------------> <----------------> <----------------> <--------------->  <----------------------> <------------> <-----------------------> <------------>
#  ------------------------ ------------ ------------------ -----------------  ================================================================================
# | IMAGE_ROOTFS_ALIGNMENT | RESIN_BOOT_SPACE | ROOTFS_SIZE      |  ROOTFS_SIZE    || IMAGE_ROOTFS_ALIGNMENT || CONFIG_SIZE || IMAGE_ROOTFS_ALIGNMENT || BTRFS_SIZE  ||
#  ------------------------ ------------------ ------------------ -----------------  ================================================================================
# ^                        ^                  ^                  ^                 ^^                        ^^             ^^                        ^^             ^^
# |                        |                  |                  |                 ||                        ||             ||                        ||             ||
# 0                      4MiB               4MiB +             4MiB +            4MiB +                      4MiB +         4MiB +                    4MiB +         4MiB +
#                                           20Mib              40MiB +           40MiB +                     40MiB +        40MiB +                   40MiB +        40MiB +
#                                                        ROOTFS_SIZE       ROOTFS_SIZE +               ROOTFS_SIZE +  ROOTFS_SIZE +             ROOTFS_SIZE +  ROOTFS_SIZE +
#                                                                          ROOTFS_SIZE                 ROOTFS_SIZE +  ROOTFS_SIZE +             ROOTFS_SIZE +  ROOTFS_SIZE +
#                                                                                                      4MiB           4MiB +                    4MiB +         4MiB +
#                                                                                                                     4MiB                      4MiB +         4MiB +
#                                                                                                                                               4MiB           4MiB +
#                                                                                                                                                              4MiB

# This image depends on the rootfs image
IMAGE_TYPEDEP_resin-sdcard = "${RESIN_SDIMG_ROOTFS_TYPE}"

# Partition labels
RESIN_BOOT_FS_LABEL ?= "resin-boot"
RESIN_ROOT_FS_LABEL ?= "resin-root"
RESIN_UPDATE_FS_LABEL ?= "resin-updt"
RESIN_CONFIG_FS_LABEL ?= "resin-conf"
RESIN_DATA_FS_LABEL ?= "resin-data"

# Boot partition size [in KiB] (will be rounded up to IMAGE_ROOTFS_ALIGNMENT)
RESIN_BOOT_SPACE ?= "40960"

# Set alignment to 4MB [in KiB]
IMAGE_ROOTFS_ALIGNMENT = "4096"

# Use an uncompressed ext3 by default as rootfs
RESIN_SDIMG_ROOTFS_TYPE ?= "ext3"
RESIN_SDIMG_ROOTFS = "${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.${RESIN_SDIMG_ROOTFS_TYPE}"

# Default bootloader to virtual/bootloader
RESIN_IMAGE_BOOTLOADER ?= "virtual/bootloader"

IMAGE_DEPENDS_resin-sdcard = " \
			e2fsprogs-native \
			parted-native \
			mtools-native \
			dosfstools-native \
			virtual/kernel \
			${RESIN_IMAGE_BOOTLOADER} \
			resin-supervisor \
			btrfs-tools-native \
			"

# SD card image name
RESIN_SDIMG ?= "${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.resin-sdcard"

# Compression method to apply to RESIN_SDIMG after it has been created. Supported
# compression formats are "gzip", "bzip2" or "xz". The original .resin-sdcard file
# is kept and a new compressed file is created if one of these compression
# formats is chosen. If RESIN_SDIMG_COMPRESSION is set to any other value it is
# silently ignored.
RESIN_SDIMG_COMPRESSION ?= ""

IMAGEDATESTAMP = "${@time.strftime('%Y.%m.%d',time.gmtime())}"

# BTRFS image
BTRFS_IMAGE = "${DEPLOY_DIR}/images/${MACHINE}/data_disk.img"

# Config size
CONFIG_SIZE = "20480"

IMAGE_CMD_resin-sdcard () {
	# Align partitions
	RESIN_BOOT_SPACE_ALIGNED=$(expr ${RESIN_BOOT_SPACE} \+ ${IMAGE_ROOTFS_ALIGNMENT} - 1)
	RESIN_BOOT_SPACE_ALIGNED=$(expr ${RESIN_BOOT_SPACE_ALIGNED} \- ${RESIN_BOOT_SPACE_ALIGNED} \% ${IMAGE_ROOTFS_ALIGNMENT})
	ROOTFS_SIZE=`du -bks ${RESIN_SDIMG_ROOTFS} | awk '{print $1}'`
	if [ -n "${BTRFS_IMAGE}" ]; then
		BTRFS_SPACE=`du -bks ${BTRFS_IMAGE} | awk '{print $1}'`
	else
		BTRFS_SPACE=${IMAGE_ROOTFS_ALIGNMENT}
	fi
	# Round up RootFS size to the alignment size as well
	ROOTFS_SIZE_ALIGNED=$(expr ${ROOTFS_SIZE} \+ ${IMAGE_ROOTFS_ALIGNMENT} \- 1)
	ROOTFS_SIZE_ALIGNED=$(expr ${ROOTFS_SIZE_ALIGNED} \- ${ROOTFS_SIZE_ALIGNED} \% ${IMAGE_ROOTFS_ALIGNMENT})
	# UPDATE alignment
	UPDATE_SIZE_ALIGNED=$(expr ${ROOTFS_SIZE} \+ ${IMAGE_ROOTFS_ALIGNMENT} \- 1)
	UPDATE_SIZE_ALIGNED=$(expr ${UPDATE_SIZE_ALIGNED} \- ${UPDATE_SIZE_ALIGNED} \% ${IMAGE_ROOTFS_ALIGNMENT})
	# BTRFS alignment
	BTRFS_SIZE_ALIGNED=$(expr ${BTRFS_SPACE} \+ ${IMAGE_ROOTFS_ALIGNMENT} \- 1)
	BTRFS_SIZE_ALIGNED=$(expr ${BTRFS_SIZE_ALIGNED} \- ${BTRFS_SIZE_ALIGNED} \% ${IMAGE_ROOTFS_ALIGNMENT})
	# Config alignment
	CONFIG_SIZE_ALIGNED=$(expr ${CONFIG_SIZE} \+ ${IMAGE_ROOTFS_ALIGNMENT} \- 1)
	CONFIG_SIZE_ALIGNED=$(expr ${CONFIG_SIZE_ALIGNED} \- ${CONFIG_SIZE_ALIGNED} \% ${IMAGE_ROOTFS_ALIGNMENT})
	SDIMG_SIZE=$(expr 3 \* ${IMAGE_ROOTFS_ALIGNMENT} \+ ${RESIN_BOOT_SPACE_ALIGNED} \+ ${ROOTFS_SIZE_ALIGNED} \+ ${UPDATE_SIZE_ALIGNED} \+ ${BTRFS_SIZE_ALIGNED} \+ ${CONFIG_SIZE_ALIGNED})

	echo "Creating filesystem with Boot partition ${RESIN_BOOT_SPACE_ALIGNED} KiB, RootFS ${ROOTFS_SIZE_ALIGNED} KiB, UpdateFS ${UPDATE_SIZE_ALIGNED} KiB, Config ${CONFIG_SIZE_ALIGNED} KiB and BTRFS ${BTRFS_SIZE_ALIGNED} KiB"
	echo "Total SD card size ${SDIMG_SIZE} KiB"

	# Initialize sdcard image file
	dd if=/dev/zero of=${RESIN_SDIMG} bs=1024 count=0 seek=${SDIMG_SIZE}

	# Create partition table
	parted -s ${RESIN_SDIMG} mklabel msdos

	# Define START and END; so the parted commands don't get too crowded
	START=${IMAGE_ROOTFS_ALIGNMENT}
	END=$(expr ${START} \+ ${RESIN_BOOT_SPACE_ALIGNED})
	# Create boot partition and mark it as bootable
	parted -s ${RESIN_SDIMG} unit KiB mkpart primary fat32 ${START} ${END}
	parted -s ${RESIN_SDIMG} set 1 boot on

	# Create rootfs partition
	START=${END}
	END=$(expr ${START} \+ ${ROOTFS_SIZE_ALIGNED})
	parted -s ${RESIN_SDIMG} unit KiB mkpart primary ext4 ${START} ${END}

	# Create update partition
	START=${END}
	END=$(expr ${START} \+ ${UPDATE_SIZE_ALIGNED})
	parted -s ${RESIN_SDIMG} unit KiB mkpart primary ext4 ${START} ${END}

	# Create extended partition
	START=${END}
	parted -s ${RESIN_SDIMG} -- unit KiB mkpart extended ${START} -1s

	# After creating the extended partition the next logical parition needs a IMAGE_ROOTFS_ALIGNMENT in front of it
	START=$(expr ${START} \+ ${IMAGE_ROOTFS_ALIGNMENT})
	END=$(expr ${START} \+ ${CONFIG_SIZE_ALIGNED})
    parted -s ${RESIN_SDIMG} unit KiB mkpart logical fat32 ${START} ${END}

	# Create BTRFS partition
	START=$(expr ${END} \+ ${IMAGE_ROOTFS_ALIGNMENT})
    parted -s ${RESIN_SDIMG} -- unit KiB mkpart logical btrfs ${START} -1s

	# Create a vfat filesystem with boot files
	BOOT_BLOCKS=$(LC_ALL=C parted -s ${RESIN_SDIMG} unit b print | awk '/ 1 / { print substr($4, 1, length($4 -1)) / 512 /2 }')
	mkfs.vfat -n "${RESIN_BOOT_FS_LABEL}" -S 512 -C ${WORKDIR}/boot.img $BOOT_BLOCKS
	echo "Copying files in RESIN_BOOT_PARTITION_FILE"
	for RESIN_BOOT_PARTITION_FILE in ${RESIN_BOOT_PARTITION_FILES}; do
		src=`echo ${RESIN_BOOT_PARTITION_FILE} | awk -F: '{print $1}'`
		dst=`echo ${RESIN_BOOT_PARTITION_FILE} | awk -F: '{print $2}'`
		if [ -z "${dst}" ]; then
			dst=`basename ${src}`
		fi
		# Create the directories mentioned in the RESIN_BOOT_PARTITION_FILE
		directory=""
		for i in `echo ${RESIN_BOOT_PARTITION_FILE} | awk -F: '{print $2}' | sed -e 's/\//\n/g' |  head -n -1 `; do
		        directory=$directory/$i
			mmd -D sS -i ${WORKDIR}/boot.img $directory || true
		done

		mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/${src} ::/${dst}
	done

    # Create a vfat filesystem for config partition
    CONFIG_BLOCKS=$(LC_ALL=C parted -s ${RESIN_SDIMG} unit b print | awk '/ 5 / { print substr($4, 1, length($4 -1)) / 512 /2 }')
    mkfs.vfat -n "${RESIN_CONFIG_FS_LABEL}" -S 512 -C ${WORKDIR}/config.img $CONFIG_BLOCKS

	# Add stamp file to vfat partition
	echo "${IMAGE_NAME}-${IMAGEDATESTAMP}" > ${WORKDIR}/image-version-info
	mcopy -i ${WORKDIR}/boot.img -v ${WORKDIR}//image-version-info ::

    # Label what is not labeled
    e2label ${RESIN_SDIMG_ROOTFS} ${RESIN_ROOT_FS_LABEL}
    if [ -n "${BTRFS_IMAGE}" ]; then
        btrfs filesystem label ${BTRFS_IMAGE} ${RESIN_DATA_FS_LABEL}
    fi

	# Burn Boot Partition
	dd if=${WORKDIR}/boot.img of=${RESIN_SDIMG} conv=notrunc seek=1 bs=$(expr ${IMAGE_ROOTFS_ALIGNMENT} \* 1024) && sync && sync
	# Burn Rootfs Partition
	dd if=${RESIN_SDIMG_ROOTFS} of=${RESIN_SDIMG} conv=notrunc seek=1 bs=$(expr 1024 \* $(expr ${RESIN_BOOT_SPACE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT})) && sync && sync
    # Burn Config Partition
    dd if=${WORKDIR}/config.img of=${RESIN_SDIMG} conv=notrunc seek=1 bs=$(expr 1024 \* $(expr ${RESIN_BOOT_SPACE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT} \+ ${ROOTFS_SIZE_ALIGNED} \+ ${UPDATE_SIZE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT})) && sync && sync
	# Burn BTRFS Partition
	if [ -n "${BTRFS_IMAGE}" ]; then
		dd if=${BTRFS_IMAGE} of=${RESIN_SDIMG} conv=notrunc seek=1 bs=$(expr 1024 \* $(expr ${RESIN_BOOT_SPACE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT} \+ ${ROOTFS_SIZE_ALIGNED} \+ ${UPDATE_SIZE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT} \+ ${CONFIG_SIZE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT})) && sync && sync
	fi
}

resin_sdcard_compress () {
	# Optionally apply compression
	case "${RESIN_SDIMG_COMPRESSION}" in
	"gzip")
		gzip -k9 "${RESIN_SDIMG}"
		;;
	"bzip2")
		bzip2 -k9 "${RESIN_SDIMG}"
		;;
	"xz")
		xz -k "${RESIN_SDIMG}"
		;;
	esac
}

IMAGE_POSTPROCESS_COMMAND += "resin_sdcard_compress;"

# Make sure we regenerate images if we modify the files that go in the boot
# partition
do_rootfs[vardeps] += "RESIN_BOOT_PARTITION_FILES"
