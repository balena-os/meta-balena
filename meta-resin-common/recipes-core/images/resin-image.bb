# Base this image on core-image-minimal
include recipes-core/images/core-image-minimal.bb

IMAGE_FEATURES_append = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'resin-staging', 'debug-tweaks', '', d)} \
    splash \
    ssh-server-dropbear \
    "

IMAGE_INSTALL_append = " \
    packagegroup-resin-connectivity \
    packagegroup-resin \
    "

generate_rootfs_fingerprints () {
    find ${IMAGE_ROOTFS} -xdev -type f -exec md5sum {} \; | sed "s#${IMAGE_ROOTFS}##g" | sort -k2 > ${IMAGE_ROOTFS}/${RESIN_ROOT_FS_LABEL}.${FINGERPRINT_EXT}
}
ROOTFS_POSTPROCESS_COMMAND += " generate_rootfs_fingerprints ; "
