include resin-image.inc

# Make sure we have the resin image and the initramfs ready
IMAGE_DEPENDS_resin-sdcard_append_nuc = " core-image-minimal-initramfs:do_rootfs"

# Put the resin image and initramfs inside the boot partition
RESIN_BOOT_PARTITION_FILES_append_nuc = " \
    resin-image-nuc.resin-sdcard \
    core-image-minimal-initramfs-nuc.cpio.gz:initramfs \
    "
