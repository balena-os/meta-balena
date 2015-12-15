include resin-image.inc

# we add bootloader to the flasher boot partition so we can burn it to SPI ROM
RESIN_BOOT_PARTITION_FILES_append_vab820-quad = " u-boot-${MACHINE}.imx:"
