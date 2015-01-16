inherit image_types

# This image depends on the rootfs image
IMAGE_TYPEDEP_beaglebone-sdimg = "${SDIMG_ROOTFS_TYPE}"

# Boot partition volume id
BOOTDD_VOLUME_ID ?= "${MACHINE}"

# Boot partition size [in KiB]
BOOT_SIZE ?= "12288"

# Config partition size [in KiB]
CONFIGFS_SIZE = "4096"

# Rootfs partition size [in KiB]
#ROOTFS_SIZE_forcevariable = "307200"

# First partition leaving 4MiB of space
IMAGE_ROOTFS_ALIGNMENT = "4096"

# Use an uncompressed ext4 by default as rootfs
SDIMG_ROOTFS_TYPE_forcevariable = "ext4"
SDIMG_ROOTFS = "${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.${SDIMG_ROOTFS_TYPE}"

IMAGE_DEPENDS_beaglebone-sdimg += " \
			parted-native \
			mtools-native \
			dosfstools-native \
			e2fsprogs-native \
			virtual/kernel \
			virtual/bootloader \
			u-boot-ti-staging-mmc \
			"

# SD card image name
SDIMG = "${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.img"

IMAGEDATESTAMP = "${@time.strftime('%Y.%m.%d',time.gmtime())}"

IMAGE_CMD_beaglebone-sdimg () {

	# Align partitions
	BOOT_SIZE_ALIGNED=$(expr ${BOOT_SIZE} + ${IMAGE_ROOTFS_ALIGNMENT} - 1)
	BOOT_SIZE_ALIGNED=$(expr ${BOOT_SIZE_ALIGNED} - ${BOOT_SIZE_ALIGNED} % ${IMAGE_ROOTFS_ALIGNMENT})
	SDIMG_SIZE=$(expr ${IMAGE_ROOTFS_ALIGNMENT} + ${BOOT_SIZE_ALIGNED} + ${ROOTFS_SIZE} + ${IMAGE_ROOTFS_ALIGNMENT} + ${CONFIGFS_SIZE})

	# Initialize sdcard image file
	dd if=/dev/zero of=${SDIMG} bs=1 count=0 seek=$(expr 1024 \* ${SDIMG_SIZE})

	# Create partition table
	parted -s ${SDIMG} mklabel msdos
	# Create boot partition and mark it as bootable
	parted -s ${SDIMG} unit KiB mkpart primary fat16 ${IMAGE_ROOTFS_ALIGNMENT} $(expr ${BOOT_SIZE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT})
	parted -s ${SDIMG} set 1 boot on
	# Create rootfs partition
	parted -s ${SDIMG} unit KiB mkpart primary ext4 $(expr ${BOOT_SIZE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT}) $(expr ${BOOT_SIZE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT} \+ ${ROOTFS_SIZE})
	# Create a config partition
	parted -s ${SDIMG} unit KiB mkpart primary ext4 $(expr ${BOOT_SIZE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT} \+ ${ROOTFS_SIZE}) $(expr ${BOOT_SIZE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT} \+ ${ROOTFS_SIZE} \+ ${CONFIGFS_SIZE})
	parted ${SDIMG} print

	# Create a vfat image with boot files
	BOOT_BLOCKS=$(LC_ALL=C parted -s ${SDIMG} unit b print | awk '/ 1 / { print substr($4, 1, length($4 -1)) / 512 /2 }')
	mkfs.vfat -n "${BOOTDD_VOLUME_ID}" -S 512 -C ${WORKDIR}/boot.img $BOOT_BLOCKS
	mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/MLO ::MLO
	mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/u-boot-mmc-beaglebone.img ::u-boot.img
	mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/u-boot.img ::u-boot-emmc.img

	# Add stamp file
	echo "${IMAGE_NAME}-${IMAGEDATESTAMP}" > ${WORKDIR}/VERSION
	mcopy -i ${WORKDIR}/boot.img -v ${WORKDIR}/VERSION ::
	
	# Burn Partitions
	dd if=${WORKDIR}/boot.img of=${SDIMG} conv=notrunc seek=1 bs=$(expr ${IMAGE_ROOTFS_ALIGNMENT} \* 1024) && sync && sync
	dd if=${SDIMG_ROOTFS} of=${SDIMG} conv=notrunc seek=1 bs=$(expr 1024 \* ${BOOT_SIZE_ALIGNED} + ${IMAGE_ROOTFS_ALIGNMENT} \* 1024) && sync && sync

	# Add symlink
	ln -sf ${SDIMG} ${DEPLOY_DIR_IMAGE}/beaglebone.img
	

}
