inherit sdcard_image-rpi

#
# Create an image that can by written onto a SD card using dd.
#
# The disk layout used is:
#
#    0                      -> IMAGE_ROOTFS_ALIGNMENT         - reserved for other data
#    IMAGE_ROOTFS_ALIGNMENT -> BOOT_SPACE                     - bootloader and kernel
#    BOOT_SPACE             -> ROOTFS_SIZE                    - rootfs
#    ROOTFS_SIZE            -> UPDATE_SIZE                    - update (this is a duplicate of rootfs so UPDATE_SIZE == ROOTFS_SIZE)
#    UPDATE_SIZE            -> SDIMG_SIZE                     - extended partition
#    
# The exended partition layout is:
#    0                      -> IMAGE_ROOTFS_ALIGNMENT         - reserved for other data
#    IMAGE_ROOTFS_ALIGNMENT -> CONFIG_SIZE                    - the config.json gets injected in here
#    CONFIG_SIZE            -> IMAGE_ROOTFS_ALIGNMENT         - reserved for other data
#    IMAGE_ROOTFS_ALIGNMENT -> SDIMG_SIZE                     - btrfs partition

#
#            4MiB              20MiB        ROOTFS_SIZE       ROOTFS_SIZE              4MiB                4MiB                 4MiB                4MiB
# <-----------------------> <----------> <----------------> <--------------->  <----------------------> <------------> <-----------------------> <------------>
#  ------------------------ ------------ ------------------ -----------------  ================================================================================
# | IMAGE_ROOTFS_ALIGNMENT | BOOT_SPACE | ROOTFS_SIZE      |  ROOTFS_SIZE    || IMAGE_ROOTFS_ALIGNMENT || CONFIG_SIZE || IMAGE_ROOTFS_ALIGNMENT || BTRFS_SIZE  ||
#  ------------------------ ------------ ------------------ -----------------  ================================================================================
# ^                        ^            ^                  ^                 ^^                        ^^             ^^                        ^^             ^^ 
# |                        |            |                  |                 ||                        ||             ||                        ||             ||
# 0                      4MiB         4MiB +             4MiB +            4MiB +                      4MiB +         4MiB +                    4MiB +         4MiB +
#                                     20Mib              20MiB +           20MiB +                     20MiB +        20MiB +                   20MiB +        20MiB +
#                                                        ROOTFS_SIZE       ROOTFS_SIZE +               ROOTFS_SIZE +  ROOTFS_SIZE +             ROOTFS_SIZE +  ROOTFS_SIZE +
#                                                                          ROOTFS_SIZE                 ROOTFS_SIZE +  ROOTFS_SIZE +             ROOTFS_SIZE +  ROOTFS_SIZE +
#                                                                                                      4MiB           4MiB +                    4MiB +         4MiB +       
#                                                                                                                     4MiB                      4MiB +         4MiB +
#                                                                                                                                               4MiB           4MiB +        
#                                                                                                                                                              4MiB

IMAGE_DEPENDS_rpi-sdimg_append = " resin-supervisor-disk"

# Kernel image name
SDIMG_KERNELIMAGE_raspberrypi  ?= "kernel.img"
SDIMG_KERNELIMAGE_raspberrypi2 ?= "kernel7.img"

# BTRFS image
BTRFS_IMAGE = "${DEPLOY_DIR}/images/${MACHINE}/data_disk.img"

# Config size
CONFIG_SIZE = "4096"

# Use an uncompressed ext3 by default as rootfs
SDIMG_ROOTFS_TYPE = "ext3"

IMAGE_CMD_rpi-sdimg () {
	# Align partitions
	BOOT_SPACE_ALIGNED=$(expr ${BOOT_SPACE} \+ ${IMAGE_ROOTFS_ALIGNMENT} - 1)
	BOOT_SPACE_ALIGNED=$(expr ${BOOT_SPACE_ALIGNED} \- ${BOOT_SPACE_ALIGNED} \% ${IMAGE_ROOTFS_ALIGNMENT})
	ROOTFS_SIZE=`du -bks ${SDIMG_ROOTFS} | awk '{print $1}'`
	BTRFS_SPACE=`du -bks ${BTRFS_IMAGE} | awk '{print $1}'`
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
	SDIMG_SIZE=$(expr 3 \* ${IMAGE_ROOTFS_ALIGNMENT} \+ ${BOOT_SPACE_ALIGNED} \+ ${ROOTFS_SIZE_ALIGNED} \+ ${UPDATE_SIZE_ALIGNED} \+ ${BTRFS_SIZE_ALIGNED} \+ ${CONFIG_SIZE_ALIGNED})

	echo "Creating filesystem with Boot partition ${BOOT_SPACE_ALIGNED} KiB and RootFS ${ROOTFS_SIZE_ALIGNED} KiB"

	# Initialize sdcard image file
	dd if=/dev/zero of=${SDIMG} bs=1024 count=0 seek=${SDIMG_SIZE}

	# Create partition table
	parted -s ${SDIMG} mklabel msdos

	# Define START and END; so the parted commands don't get too crowded
	START=${IMAGE_ROOTFS_ALIGNMENT}
	END=$(expr ${START} \+ ${BOOT_SPACE_ALIGNED})
	# Create boot partition and mark it as bootable
	parted -s ${SDIMG} unit KiB mkpart primary fat32 ${START} ${END}
	parted -s ${SDIMG} set 1 boot on

	# Create rootfs partition
	START=${END}
	END=$(expr ${START} \+ ${ROOTFS_SIZE_ALIGNED})
	parted -s ${SDIMG} unit KiB mkpart primary ext4 ${START} ${END}

	# Create update partition
	START=${END}
	END=$(expr ${START} \+ ${UPDATE_SIZE_ALIGNED})
	parted -s ${SDIMG} unit KiB mkpart primary ext4 ${START} ${END}

	# Create extended partition 
	START=${END}
	parted -s ${SDIMG} -- unit KiB mkpart extended ${START} -1s

	# After creating the extended partition the next logical parition needs a IMAGE_ROOTFS_ALIGNMENT in front of it
	START=$(expr ${START} \+ ${IMAGE_ROOTFS_ALIGNMENT})
	END=$(expr ${START} \+ ${CONFIG_SIZE_ALIGNED})
	parted -s ${SDIMG} unit KiB mkpart logical ext2 ${START} ${END}

	# Create BTRFS partition
	START=$(expr ${END} \+ ${IMAGE_ROOTFS_ALIGNMENT})
	parted -s ${SDIMG} -- unit KiB mkpart logical ext2 ${START} -1s

	# Create a vfat image with boot files
	BOOT_BLOCKS=$(LC_ALL=C parted -s ${SDIMG} unit b print | awk '/ 1 / { print substr($4, 1, length($4 -1)) / 512 /2 }')
	mkfs.vfat -n "${BOOTDD_VOLUME_ID}" -S 512 -C ${WORKDIR}/boot.img $BOOT_BLOCKS
	mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/bcm2835-bootfiles/* ::/
	case "${KERNEL_IMAGETYPE}" in
	"uImage")
		mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/u-boot.img ::${SDIMG_KERNELIMAGE}
		mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-${MACHINE}.bin ::uImage
		;;
	*)
		if test -n "${KERNEL_DEVICETREE}"; then
			# Copy board device trees to root folder
			for DTB in ${DT_ROOT}; do
				DTB_BASE_NAME=`basename ${DTB} .dtb`

				mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${DTB_BASE_NAME}.dtb ::${DTB_BASE_NAME}.dtb
			done

			# Copy device tree overlays to dedicated folder
			mmd -i ${WORKDIR}/boot.img overlays
			for DTB in ${DT_OVERLAYS}; do
				DTB_BASE_NAME=`basename ${DTB} .dtb`

				mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${DTB_BASE_NAME}.dtb ::overlays/${DTB_BASE_NAME}.dtb
			done
		fi
		mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-${MACHINE}.bin ::${SDIMG_KERNELIMAGE}
		;;
	esac

	# Add stamp file
	echo "${IMAGE_NAME}-${IMAGEDATESTAMP}" > ${WORKDIR}/image-version-info
	mcopy -i ${WORKDIR}/boot.img -v ${WORKDIR}//image-version-info ::

	# Burn Partitions
	dd if=${WORKDIR}/boot.img of=${SDIMG} conv=notrunc seek=1 bs=$(expr ${IMAGE_ROOTFS_ALIGNMENT} \* 1024) && sync && sync
	
	# Burn Rootfs
	dd if=${SDIMG_ROOTFS} of=${SDIMG} conv=notrunc seek=1 bs=$(expr 1024 \* $(expr ${BOOT_SPACE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT})) && sync && sync

	# Burn BTRFS partition
	dd if=${BTRFS_IMAGE} of=${SDIMG} conv=notrunc seek=1 bs=$(expr 1024 \* $(expr ${BOOT_SPACE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT} \+ ${ROOTFS_SIZE_ALIGNED} \+ ${UPDATE_SIZE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT} \+ ${CONFIG_SIZE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT})) && sync && sync
}
