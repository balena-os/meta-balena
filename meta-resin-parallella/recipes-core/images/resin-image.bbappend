IMAGE_FSTYPES_parallella-hdmi-resin = "resin-sdcard"

SDIMG_KERNELIMAGE_parallella-hdmi-resin = "uImage"

# Customize resin-sdcard
RESIN_IMAGE_BOOTLOADER_parallella-hdmi-resin = ""
RESIN_BOOT_PARTITION_FILES_parallella-hdmi-resin = " \
    ${SDIMG_KERNELIMAGE} \
    "
