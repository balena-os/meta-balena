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

QUIRK_FILES ?= "etc/hostname etc/hosts etc/resolv.conf"

IMAGE_CMD_resinhup-tar () {
    # Prepare
    rm -rf ${RESIN_HUP_TEMP_DIR}
    mkdir -p ${RESIN_HUP_TEMP_DIR_BOOT}

    # Populate
    mcopy -i ${WORKDIR}/boot.img -sv ::/ ${RESIN_HUP_TEMP_DIR_BOOT}
    tar -xf ${IMAGE_NAME}.rootfs.tar -C ${RESIN_HUP_TEMP_DIR}

    # Quirks
    # We need to save some files that docker shadows with bind mounts
    # https://docs.docker.com/engine/userguide/networking/default_network/configure-dns/
    # Make sure you run this before packing
    if [ "${QUIRK_FILES}" != "" ];then
        for file in ${QUIRK_FILES}; do
            src=${RESIN_HUP_TEMP_DIR}/$file
            dst=${RESIN_HUP_TEMP_DIR}/quirks/$file
            if [ -f $src ]; then
                mkdir -p $(dirname $dst)
                cp $src $dst
            else
                bbfatal "Quirks: $src doesn't exist."
            fi
        done
    fi

    # Pack
    tar -cvf ${RESIN_HUP_BUNDLE} -C ${RESIN_HUP_TEMP_DIR} .
}
