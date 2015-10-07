# Base this image on core-image-minimal
include recipes-core/images/core-image-minimal.bb

# Make sure we have enough space in boot partition
RESIN_BOOT_SPACE = "1638400"

# Make sure you have the resin image ready
IMAGE_DEPENDS_resin-sdcard_append = " resin-image:do_rootfs"

IMAGE_FEATURES_append = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'resin-staging', 'debug-tweaks', '', d)} \
    splash \
    "

IMAGE_INSTALL_append = " \
    packagegroup-resin-connectivity \
    packagegroup-resin-flasher \
    "

# Avoid useless space by not using any btrfs partition
BTRFS_IMAGE = ""

# Avoid naming clash with resin image labels
RESIN_BOOT_FS_LABEL = "flash-boot"
RESIN_ROOT_FS_LABEL = "flash-root"
RESIN_UPDATE_FS_LABEL = "flash-updt"
RESIN_CONFIG_FS_LABEL = "flash-conf"

# Put the resin image inside the boot partition
RESIN_BOOT_PARTITION_FILES_append = " resin-image-${MACHINE}.resin-sdcard"
