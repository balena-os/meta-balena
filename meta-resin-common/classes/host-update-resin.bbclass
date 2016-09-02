inherit image_types

# This image depends on the rootfs image exported as tar and needs the temporary boot image
# from resin-sdcard
IMAGE_TYPEDEP_resinhup-tar = "tar resin-sdcard"

IMAGE_DEPENDS_resinhup-tar = " \
    tar-native \
    mtools-native \
    "

RESIN_HUP_TEMP_DIR = "${WORKDIR}/resinhup"
RESIN_HUP_TEMP_DIR_BOOT = "${RESIN_HUP_TEMP_DIR}/${RESIN_BOOT_FS_LABEL}"

RESIN_HUP_BUNDLE ?= "${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.resinhup-tar"

IMAGE_CMD_resinhup-tar () {
    # Prepare
    rm -rf ${RESIN_HUP_TEMP_DIR}
    mkdir -p ${RESIN_HUP_TEMP_DIR_BOOT}

    # Populate
    mcopy -i ${WORKDIR}/boot.img -sv ::/ ${RESIN_HUP_TEMP_DIR_BOOT}
    tar -xf ${IMAGE_NAME}.rootfs.tar -C ${RESIN_HUP_TEMP_DIR}

    # Pack
    tar -cvf ${RESIN_HUP_BUNDLE} -C ${RESIN_HUP_TEMP_DIR} .
}
