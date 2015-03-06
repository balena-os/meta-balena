IMAGE_FSTYPES_rpi = "resin-sdcard"

# Kernel image name is different on Raspberry Pi 1/2
SDIMG_KERNELIMAGE_raspberrypi  ?= "kernel.img"
SDIMG_KERNELIMAGE_raspberrypi2 ?= "kernel7.img"

# Customize resin-sdcard
RESIN_IMAGE_BOOTLOADER_rpi = "bcm2835-bootfiles"
RESIN_BOOT_PARTITION_FILES_rpi = " \
	${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-${MACHINE}.bin:${SDIMG_KERNELIMAGE} \
	bcm2835-bootfiles/* \
	"
