IMAGE_FSTYPES_rpi = "resin-sdcard"

# Kernel image name is different on Raspberry Pi 1/2
SDIMG_KERNELIMAGE_raspberrypi  ?= "kernel.img"
SDIMG_KERNELIMAGE_raspberrypi2 ?= "kernel7.img"

# Customize resin-sdcard
RESIN_IMAGE_BOOTLOADER_rpi = "bcm2835-bootfiles"
RESIN_BOOT_PARTITION_FILES_rpi = " \
    ${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-${MACHINE}.bin:${SDIMG_KERNELIMAGE} \
    bcm2835-bootfiles/* \
    ${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-bcm2708-rpi-b.dtb:bcm2708-rpi-b.dtb \
    ${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-bcm2708-rpi-b-plus.dtb:bcm2708-rpi-b-plus.dtb \
    ${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-bcm2709-rpi-2-b.dtb:bcm2709-rpi-2-b.dtb \
    ${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-ds1307-rtc-overlay.dtb:ds1307-rtc-overlay.dtb \
    ${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-hifiberry-amp-overlay.dtb:hifiberry-amp-overlay.dtb \
    ${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-hifiberry-dac-overlay.dtb:hifiberry-dac-overlay.dtb\
    ${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-hifiberry-dacplus-overlay.dtb:hifiberry-dacplus-overlay.dtb \
    ${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-hifiberry-digi-overlay.dtb:hifiberry-digi-overlay.dtb \
    ${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-iqaudio-dac-overlay.dtb:iqaudio-dac-overlay.dtb \
    ${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-iqaudio-dacplus-overlay.dtb:iqaudio-dacplus-overlay.dtb \
    ${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-lirc-rpi-overlay.dtb:lirc-rpi-overlay.dtb \
    ${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-pcf8523-rtc-overlay.dtb:pcf8523-rtc-overlay.dtb \
    ${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-pps-gpio-overlay.dtb:pps-gpio-overlay.dtb \
    ${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-w1-gpio-overlay.dtb:w1-gpio-overlay.dtb \
    ${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-w1-gpio-pullup-overlay.dtb:w1-gpio-pullup-overlay.dtb \
    "
