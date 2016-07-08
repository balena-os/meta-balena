#
# Resin images customizations
#

# When building a Resin OS image, we also generate the kernel modules headers
# and ship them in the deploy directory for out-of-tree kernel modules build
DEPENDS += "kernel-modules-headers"

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

#
# We need run depmod even if the modules are compressed
# Inspired from rootfs.py
#
def check_for_compressed_kernel_modules(modules_dir):
    for root, dirs, files in os.walk(modules_dir, topdown=True):
        for name in files:
            found_ko = name.endswith(".ko.gz") or name.endswith(".ko.xz")
            if found_ko:
                return found_ko
    return False
fakeroot python generate_compressed_kernel_module_deps() {
    import subprocess

    image_rootfs = d.getVar('IMAGE_ROOTFS', True)
    modules_dir = os.path.join(image_rootfs, 'lib', 'modules')

    # if we don't have any modules don't bother to do the depmod
    if not check_for_compressed_kernel_modules(modules_dir):
        bb.note("No Compressed Kernel Modules found, not running depmod")
        return

    kernel_abi_ver_file = oe.path.join(d.getVar('PKGDATA_DIR', True), "kernel-depmod",
                                           'kernel-abiversion')
    if not os.path.exists(kernel_abi_ver_file):
        bb.fatal("No kernel-abiversion file found (%s), cannot run depmod, aborting" % kernel_abi_ver_file)

    kernel_ver = open(kernel_abi_ver_file).read().strip(' \n')
    versioned_modules_dir = os.path.join(image_rootfs, modules_dir, kernel_ver)

    bb.utils.mkdirhier(versioned_modules_dir)

    exec_cmd = ['depmodwrapper', '-a', '-b', image_rootfs, kernel_ver]

    try:
        subprocess.check_output(exec_cmd, stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as e:
        return("Command '%s' returned %d:\n%s" % (e.cmd, e.returncode, e.output))
}

#
# Cleanup backup files
#
remove_backup_files () {
    BACKUP_FILES="/etc/passwd- /etc/shadow- /etc/group- /etc/gshadow-"
    for file in $BACKUP_FILES; do
        if [ -f "${IMAGE_ROOTFS}$file" ]; then
            rm ${IMAGE_ROOTFS}$file
        fi
    done
}

ROOTFS_POSTPROCESS_COMMAND += "generate_compressed_kernel_module_deps ; "
IMAGE_POSTPROCESS_COMMAND =+ "deploy_image_license_manifest ; fix_hddimg_symlink ; "
IMAGE_PREPROCESS_COMMAND += "remove_backup_files ; "
