#
# Resin images customizations
#

# Deploy license.manifest
DEPLOY_IMAGE_LICENSE_MANIFEST = "${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.license.manifest"
DEPLOY_SYMLINK_IMAGE_LICENSE_MANIFEST = "${DEPLOY_DIR_IMAGE}/${IMAGE_LINK_NAME}.license.manifest"
IMAGE_LICENSE_MANIFEST = "${LICENSE_DIRECTORY}/${IMAGE_NAME}/license.manifest"
# Deploy the license.manifest of the current image we baked
deploy_image_license_manifest () {
    cp -f ${IMAGE_LICENSE_MANIFEST} ${DEPLOY_IMAGE_LICENSE_MANIFEST}
    ln -sf ${IMAGE_NAME}.rootfs.license.manifest ${DEPLOY_SYMLINK_IMAGE_LICENSE_MANIFEST}
}

# _remove_old_symlinks removes the hddimg symlink
# Recreate it after image is created
fix_hddimg_symlink () {
    if [ -f ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.hddimg ]; then
        ln -s ${IMAGE_NAME}.hddimg ${DEPLOY_DIR_IMAGE}/${IMAGE_LINK_NAME}.hddimg
    fi
}

IMAGE_POSTPROCESS_COMMAND =+ "deploy_image_license_manifest ; fix_hddimg_symlink ; "
