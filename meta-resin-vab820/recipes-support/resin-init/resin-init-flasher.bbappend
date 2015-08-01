# the type of bootloader the target board uses
BOARD_BOOTLOADER_vab820-quad = "u-boot"

# On VIA VAB 820 quad, we flash on the emmc - mmcblk0
INTERNAL_DEVICE_KERNEL_vab820-quad = "mmcblk0"

# uBoot knows eMMC as mmc dev 1
INTERNAL_DEVICE_UBOOT_vab820-quad = "1"
