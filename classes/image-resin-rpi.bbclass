inherit image_types

#
# Create an image that can by written onto a SD card using dd.
#
# The disk layout used is:
#
#    0                      -> IMAGE_ROOTFS_ALIGNMENT         - reserved for other data
#    IMAGE_ROOTFS_ALIGNMENT -> BOOT_SPACE                     - bootloader and kernel
#    BOOT_SPACE             -> SDIMG_SIZE                     - rootfs
#

#                                                     Default Free space = 1.3x
#                                                     Use IMAGE_OVERHEAD_FACTOR to add more space
#                                                     <--------->
#            4MiB              20MiB           SDIMG_ROOTFS
# <-----------------------> <----------> <---------------------->
#  ------------------------ ------------ ------------------------
# | IMAGE_ROOTFS_ALIGNMENT | BOOT_SPACE | ROOTFS_SIZE            |
#  ------------------------ ------------ ------------------------
# ^                        ^            ^                        ^
# |                        |            |                        |
# 0                      4MiB     4MiB + 20MiB       4MiB + 20Mib + SDIMG_ROOTFS

# This image depends on the rootfs image
IMAGE_TYPEDEP_resin-rpi-sdimg = "${SDIMG_ROOTFS_TYPE}"

# Set kernel and boot loader
IMAGE_BOOTLOADER ?= "bcm2835-bootfiles"

# Set initramfs extension
KERNEL_INITRAMFS ?= ""

# Boot partition volume id
BOOTDD_VOLUME_ID ?= "${MACHINE}"

# Boot partition size [in KiB] (will be rounded up to IMAGE_ROOTFS_ALIGNMENT)
BOOT_SPACE ?= "20480"

# Set alignment to 4MB [in KiB]
IMAGE_ROOTFS_ALIGNMENT = "4096"

# Use an uncompressed ext3 by default as rootfs
SDIMG_ROOTFS_TYPE ?= "ext3"
SDIMG_ROOTFS = "${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.${SDIMG_ROOTFS_TYPE}"

IMAGE_DEPENDS_resin-rpi-sdimg = " \
			parted-native \
			mtools-native \
			dosfstools-native \
			virtual/kernel \
			${IMAGE_BOOTLOADER} \
			${@base_contains("KERNEL_IMAGETYPE", "uImage", "u-boot", "",d)} \
			"

# SD card image name
SDIMG_forcevariable  = "${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.resin.img"

# Compression method to apply to SDIMG after it has been created. Supported
# compression formats are "gzip", "bzip2" or "xz". The original .rpi-sdimg file
# is kept and a new compressed file is created if one of these compression
# formats is chosen. If SDIMG_COMPRESSION is set to any other value it is
# silently ignored.
SDIMG_COMPRESSION ?= "xz"

# Additional files and/or directories to be copied into the vfat partition from the IMAGE_ROOTFS.
FATPAYLOAD ?= ""

IMAGEDATESTAMP = "${@time.strftime('%Y.%m.%d',time.gmtime())}"

IMAGE_CMD_resin-rpi-sdimg () {

	# Align partitions
	BOOT_SPACE_ALIGNED=$(expr ${BOOT_SPACE} + ${IMAGE_ROOTFS_ALIGNMENT} - 1)
	BOOT_SPACE_ALIGNED=$(expr ${BOOT_SPACE_ALIGNED} - ${BOOT_SPACE_ALIGNED} % ${IMAGE_ROOTFS_ALIGNMENT})
	ROOTFS_SIZE=`du -bks ${SDIMG_ROOTFS} | awk '{print $1}'`
        # Round up RootFS size to the alignment size as well
	ROOTFS_SIZE_ALIGNED=$(expr ${ROOTFS_SIZE} + ${IMAGE_ROOTFS_ALIGNMENT} - 1)
	ROOTFS_SIZE_ALIGNED=$(expr ${ROOTFS_SIZE_ALIGNED} - ${ROOTFS_SIZE_ALIGNED} % ${IMAGE_ROOTFS_ALIGNMENT} + 90000)
	SDIMG_SIZE=$(expr ${IMAGE_ROOTFS_ALIGNMENT} + ${BOOT_SPACE_ALIGNED} + ${ROOTFS_SIZE_ALIGNED})

	echo "Creating filesystem with Boot partition ${BOOT_SPACE_ALIGNED} KiB and RootFS ${ROOTFS_SIZE_ALIGNED} KiB"

	# Initialize sdcard image file
	dd if=/dev/zero of=${SDIMG} bs=1024 count=0 seek=${SDIMG_SIZE}

	# Create partition table
	parted -s ${SDIMG} mklabel msdos
	# Create boot partition and mark it as bootable
	parted -s ${SDIMG} unit KiB mkpart primary fat32 ${IMAGE_ROOTFS_ALIGNMENT} $(expr ${BOOT_SPACE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT})
	parted -s ${SDIMG} set 1 boot on
	# Create rootfs partition to the end of disk
	parted -s ${SDIMG} -- unit KiB mkpart primary ext2 $(expr ${BOOT_SPACE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT}) -1s
	parted ${SDIMG} print

	# Create a vfat image with boot files
	BOOT_BLOCKS=$(LC_ALL=C parted -s ${SDIMG} unit b print | awk '/ 1 / { print substr($4, 1, length($4 -1)) / 512 /2 }')
	mkfs.vfat -n "${BOOTDD_VOLUME_ID}" -S 512 -C ${WORKDIR}/boot.img $BOOT_BLOCKS
	mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/bcm2835-bootfiles/* ::/
	case "${KERNEL_IMAGETYPE}" in
	"uImage")
	    mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/u-boot.img ::kernel.img
	    mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-${MACHINE}.bin ::uImage
	    ;;
	*)
	    mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-${MACHINE}.bin ::kernel.img
	    ;;
	esac

	if [ -n ${FATPAYLOAD} ] ; then
		echo "Copying payload into VFAT"
		for entry in ${FATPAYLOAD} ; do
				# add the || true to stop aborting on vfat issues like not supporting .~lock files
				mcopy -i ${WORKDIR}/boot.img -s -v ${IMAGE_ROOTFS}$entry :: || true
		done
	fi

	# Add stamp file
	echo "${IMAGE_NAME}-${IMAGEDATESTAMP}" > ${WORKDIR}/image-version-info
	mcopy -i ${WORKDIR}/boot.img -v ${WORKDIR}//image-version-info ::

	# Burn Partitions
	dd if=${WORKDIR}/boot.img of=${SDIMG} conv=notrunc seek=1 bs=$(expr ${IMAGE_ROOTFS_ALIGNMENT} \* 1024) && sync && sync
	# If SDIMG_ROOTFS_TYPE is a .xz file use xzcat
	if echo "${SDIMG_ROOTFS_TYPE}" | egrep -q "*\.xz"
	then
		xzcat ${SDIMG_ROOTFS} | dd of=${SDIMG} conv=notrunc seek=1 bs=$(expr 1024 \* ${BOOT_SPACE_ALIGNED} + ${IMAGE_ROOTFS_ALIGNMENT} \* 1024) && sync && sync
	else
		dd if=${SDIMG_ROOTFS} of=${SDIMG} conv=notrunc seek=1 bs=$(expr 1024 \* ${BOOT_SPACE_ALIGNED} + ${IMAGE_ROOTFS_ALIGNMENT} \* 1024) && sync && sync
	fi

	# Optionally apply compression
	case "${SDIMG_COMPRESSION}" in
	"gzip")
		gzip -k9 "${SDIMG}"
		;;
	"bzip2")
		bzip2 -k9 "${SDIMG}"
		;;
	"xz")
		xz -k "${SDIMG}"
		;;
	esac
}

ROOTFS_POSTPROCESS_COMMAND += " resin_rpi_generate_sysctl_config ; "

resin_rpi_generate_sysctl_config() {
	# systemd sysctl config
	test -d ${IMAGE_ROOTFS}${sysconfdir}/sysctl.d && \
		echo "vm.min_free_kbytes = 8192" > ${IMAGE_ROOTFS}${sysconfdir}/sysctl.d/rpi-vm.conf

	# sysv sysctl config
	IMAGE_SYSCTL_CONF="${IMAGE_ROOTFS}${sysconfdir}/sysctl.conf"
	test -e ${IMAGE_ROOTFS}${sysconfdir}/sysctl.conf && \
		sed -e "/vm.min_free_kbytes/d" -i ${IMAGE_SYSCTL_CONF}
	echo "" >> ${IMAGE_SYSCTL_CONF} && echo "vm.min_free_kbytes = 8192" >> ${IMAGE_SYSCTL_CONF}
}
