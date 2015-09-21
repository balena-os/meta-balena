# Flash to internal eMMC - kernel enumerates this, when SD card is in, as mmcblk2
INTERNAL_DEVICE_KERNEL_ts4900 = "mmcblk2"

# Partition onto which the bootloader needs to be flashed to
BOOTLOADER_FLASH_DEVICE_ts4900 = "mtdblock0"

# Name of u-boot image
BOOTLOADER_IMAGE_ts4900 = "uboot.imx"

# Offset at which we flash u-boot binary
BOOTLOADER_BLOCK_SIZE_OFFSET_ts4900 = "1024"
