include resin-image.inc

#
# ts4900
#

# The bootloader gets flashed by resin-image-flasher
RESIN_IMAGE_BOOTLOADER_ts4900 = ""

#
# ts7700
#
IMAGE_FSTYPES_append_ts7700 = " resin-sdcard"

IMAGE_CMD_resin-sdcard_append_ts7700 () {
    bbnote "TS7700 specific resin-sdcard configuration"

    # Burn the second stage bootloader
    dd if=${DEPLOY_DIR_IMAGE}/bootstrap-code.img of=${RESIN_SDIMG} conv=notrunc ; sync ; sync

    # Prepare raw partition for kernel
    dd if=/dev/zero of=${RESIN_SDIMG} seek=1 count=$(expr ${RESIN_BOOT_SPACE_ALIGNED} \/ ${IMAGE_ROOTFS_ALIGNMENT}) conv=notrunc bs=$(expr ${IMAGE_ROOTFS_ALIGNMENT} \* 1024) ; sync ; sync

    # Burn kernel
    dd if=${DEPLOY_DIR_IMAGE}/zImage of=${RESIN_SDIMG} seek=1 conv=notrunc bs=$(expr ${IMAGE_ROOTFS_ALIGNMENT} \* 1024) ; sync ; sync

    # Set non-fs part-type for the boot partition (this is required by the bootloader)
    sfdisk -c  ${RESIN_SDIMG} 1 da
}
