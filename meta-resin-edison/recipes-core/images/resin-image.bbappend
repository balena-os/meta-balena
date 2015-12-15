NOHDD_edison = "0"

inherit bootimg

# TODO
# This was already fixed in poky but fix was not backported to daisy
# To be removed in the future
do_bootimg[depends] += "virtual/kernel:do_deploy"

# Do not use legacy nor EFI BIOS
PCBIOS_edison = "0"

# Specify rootfs image type
IMAGE_FSTYPES_append_edison = " hddimg"

BOOTIMG_VOLUME_ID_edison = "resin-boot"

DEPENDS_append_edison = "\
    edison-dfu \
    btrfs-tools-native \
    dosfstools-native \
    e2fsprogs-native \
    "

IMAGE_INSTALL_append_edison = " packagegroup-edison"

IMAGE_POSTPROCESS_COMMAND_append_edison = " \
    define_labels; \
    deploy_bundle; \
    "

define_labels() {
    #Missing labels
    e2label ${DEPLOY_DIR_IMAGE}/resin-image-edison.ext3 ${RESIN_ROOT_FS_LABEL}
    btrfs filesystem label ${DEPLOY_DIR_IMAGE}/data_disk.img ${RESIN_DATA_FS_LABEL}
}

deploy_bundle() {
    #Create empty vfat filesystem for out config partition
    CONFIG_BLOCKS=${CONFIG_SIZE}
    mkfs.vfat -n "${RESIN_CONFIG_FS_LABEL}" -S 512 -C ${DEPLOY_DIR_IMAGE}/config.img $CONFIG_BLOCKS

    mkdir -p ${DEPLOY_DIR_IMAGE}/resin-edison
    cp -rL ${DEPLOY_DIR_IMAGE}/u-boot-edison.bin ${DEPLOY_DIR_IMAGE}/resin-edison/
    cp -rL ${DEPLOY_DIR_IMAGE}/u-boot-edison.img ${DEPLOY_DIR_IMAGE}/resin-edison/
    cp -rL ${DEPLOY_DIR_IMAGE}/u-boot-envs ${DEPLOY_DIR_IMAGE}/resin-edison/
    cp -rL ${DEPLOY_DIR_IMAGE}/resin-image-edison.ext3 ${DEPLOY_DIR_IMAGE}/resin-edison/
    cp -rL ${DEPLOY_DIR_IMAGE}/data_disk.img ${DEPLOY_DIR_IMAGE}/resin-edison/
    cp -rL ${DEPLOY_DIR_IMAGE}/config.img ${DEPLOY_DIR_IMAGE}/resin-edison/
}

build_hddimg_append_edison() {
    cp -rL ${DEPLOY_DIR_IMAGE}/resin-image-edison.hddimg ${DEPLOY_DIR_IMAGE}/resin-edison/
}
