IMAGE_FSTYPES_parallella = "resin-sdcard"

SDIMG_KERNELIMAGE_parallella = "uImage"

# Customize resin-sdcard
RESIN_IMAGE_BOOTLOADER_parallella = ""
RESIN_BOOT_PARTITION_FILES_parallella = " \
	${SDIMG_KERNELIMAGE} \
	parallella-mmc-boot.dtb:devicetree.dtb \
	"
