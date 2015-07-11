# the type of bootloader the target board uses
BOARD_BOOTLOADER_beaglebone = "u-boot"

# Flash to internal eMMC - kernel enumerates this, when SD card is in, as mmcblk1
INTERNAL_DEVICE_KERNEL_beaglebone = "mmcblk1"

# uBoot knows eMMC as mmc dev 1
INTERNAL_DEVICE_UBOOT_beaglebone = "1"
