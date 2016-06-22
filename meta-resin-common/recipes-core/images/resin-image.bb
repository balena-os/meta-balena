# Base this image on core-image-minimal
include recipes-core/images/core-image-minimal.bb

inherit image-resin

#
# Set size of rootfs at a fixed value of maximum 180MiB
#

# keep this aligned to IMAGE_ROOTFS_ALIGNMENT
IMAGE_ROOTFS_SIZE = "180224"

# No overhead factor
IMAGE_OVERHEAD_FACTOR = "1.0"

# No extra space
IMAGE_ROOTFS_EXTRA_SPACE = "0"

# core-image-minimal add 4M to IMAGE_ROOTFS_EXTRA_SPACE
# Make IMAGE_ROOTFS_MAXSIZE = IMAGE_ROOTFS_SIZE + 4M
IMAGE_ROOTFS_MAXSIZE = "184320"


# Generated resinhup-tar based on RESINHUP variable
IMAGE_FSTYPES = "${@bb.utils.contains('RESINHUP', 'yes', 'resinhup-tar', '', d)}"

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

generate_hostos_version () {
    echo "${HOSTOS_VERSION}" > ${DEPLOY_DIR_IMAGE}/VERSION_HOSTOS
}

ROOTFS_POSTPROCESS_COMMAND += " generate_rootfs_fingerprints ; "
IMAGE_POSTPROCESS_COMMAND += " generate_hostos_version ; "

RESIN_BOOT_PARTITION_FILES_append = " resin-logo.png:/splash/resin-logo.png"

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
do_rootfs[postfuncs] += "generate_compressed_kernel_module_deps"
