# On VIA VAB 820 quad, we flash on the emmc - mmcblk0
INTERNAL_DEVICE_KERNEL_vab820-quad = "mmcblk0"

# uBoot knows eMMC as mmc dev 1
INTERNAL_DEVICE_UBOOT_vab820-quad = "1"

# Partition onto which the bootloader needs to be flashed to
BOOTLOADER_FLASH_DEVICE_vab820-quad = "mtdblock0"

# Name of u-boot image
BOOTLOADER_IMAGE_vab820-quad = "u-boot-${MACHINE}.imx"

# Offset at which we flash u-boot binary
BOOTLOADER_BLOCK_SIZE_OFFSET_vab820-quad = "512"

# Skipped output blocks when writing u-boot to SPI ROM
BOOTLOADER_SKIP_OUTPUT_BLOCKS_vab820-quad = "2"
