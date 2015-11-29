#
# ODROID-UX4 / ODROID-UX3
#

IMAGE_FSTYPES_append_odroid-ux3 = " resin-sdcard"

# Customize resin-sdcard
RESIN_BOOT_PARTITION_FILES_odroid-ux3 = " \
    boot.ini: \
    zImage: \
    zImage-exynos5422-odroidxu3.dtb:/exynos5422-odroidxu3.dtb \
    "

# BOOT components
UBOOT_B1_POS_odroid-ux3 ?= "1"
UBOOT_B2_POS_odroid-ux3 ?= "31"
UBOOT_BIN_POS_odroid-ux3 ?= "63"
UBOOT_TZSW_POS_odroid-ux3 ?= "719"
UBOOT_ENV_POS_odroid-ux3 ?= "1231"

IMAGE_CMD_resin-sdcard_append_odroid-ux3 () {
    # odroid-ux3 needs bootloader files written at specific locations
    dd if=${DEPLOY_DIR_IMAGE}/bl1.bin.hardkernel of=${RESIN_SDIMG} conv=notrunc seek=${UBOOT_B1_POS}
    dd if=${DEPLOY_DIR_IMAGE}/bl2.bin.hardkernel of=${RESIN_SDIMG} conv=notrunc seek=${UBOOT_B2_POS}
    dd if=${DEPLOY_DIR_IMAGE}/u-boot.${UBOOT_SUFFIX} of=${RESIN_SDIMG} conv=notrunc seek=${UBOOT_BIN_POS}
    dd if=${DEPLOY_DIR_IMAGE}/tzsw.bin.hardkernel of=${RESIN_SDIMG} conv=notrunc seek=${UBOOT_TZSW_POS}
    dd if=/dev/zero of=${RESIN_SDIMG} seek=${UBOOT_ENV_POS} conv=notrunc count=32 bs=512
}

#
# ODROID-C1
#

IMAGE_FSTYPES_append_odroid-c1 = " resin-sdcard"

# Customize resin-sdcard
RESIN_BOOT_PARTITION_FILES_odroid-c1 = " \
    boot.ini: \
    uImage: \
    uImage-meson8b_odroidc.dtb:/meson8b_odroidc.dtb \
    "

IMAGE_CMD_resin-sdcard_append_odroid-c1 () {
    dd if=${DEPLOY_DIR_IMAGE}/bl1.bin.hardkernel of=${RESIN_SDIMG} bs=1 count=442 conv=notrunc
    dd if=${DEPLOY_DIR_IMAGE}/bl1.bin.hardkernel of=${RESIN_SDIMG} bs=512 skip=1 seek=1 conv=notrunc
    dd if=${DEPLOY_DIR_IMAGE}/u-boot.bin of=${RESIN_SDIMG} bs=512 seek=64 conv=notrunc
}
