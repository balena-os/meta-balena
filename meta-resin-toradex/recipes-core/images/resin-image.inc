#
# Apalis imx6
#

IMAGE_FSTYPES_append_apalis-imx6 = " resin-sdcard"

# Customize resin-sdcard
RESIN_IMAGE_BOOTLOADER_apalis-imx6 = "u-boot"

RESIN_BOOT_PARTITION_FILES_apalis-imx6 = " \
    ${KERNEL_IMAGETYPE}-${MACHINE}.bin:/${KERNEL_IMAGETYPE} \
    uImage-imx6q-apalis-eval_v1_0.dtb:/imx6q-apalis-eval_v1_0.dtb \
    uImage-imx6q-apalis-eval.dtb:/imx6q-apalis-eval.dtb \
    "

#
# Colibri imx6
#

IMAGE_FSTYPES_append_colibri-imx6 = " resin-sdcard"

# Customize resin-sdcard
RESIN_IMAGE_BOOTLOADER_colibri-imx6 = "u-boot"

RESIN_BOOT_PARTITION_FILES_colibri-imx6 = " \
    ${KERNEL_IMAGETYPE}-${MACHINE}.bin:/${KERNEL_IMAGETYPE} \
    uImage-imx6dl-colibri-eval-v3.dtb:/imx6dl-colibri-eval-v3.dtb \
    "
