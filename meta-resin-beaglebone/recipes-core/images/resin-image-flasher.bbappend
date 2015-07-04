include resin-image.inc

# Make sure you have the resin image ready
IMAGE_DEPENDS_resin-sdcard_append_beaglebone = " resin-image:do_rootfs"

# Make sure we have enough space in boot partition
BOOT_SPACE_beaglebone = "1572864"

# Put the resin image inside boot partition
RESIN_BOOT_PARTITION_FILES_append_beaglebone = " resin-image-beaglebone.resin-sdcard"

# Avoid useless space by not using any btrfs partition
BTRFS_IMAGE_beaglebone = ""

# Avoid naming clash with resin image labels
RESIN_BOOT_FS_LABEL = "flash-boot"
RESIN_ROOT_FS_LABEL = "flash-root"
RESIN_UPDATE_FS_LABEL = "flash-updt"
RESIN_CONFIG_FS_LABEL = "flash-conf"
RESIN_DATA_FS_LABEL = "flh-data"
