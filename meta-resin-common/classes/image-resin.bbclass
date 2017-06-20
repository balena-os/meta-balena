#
# Resin images customizations
#

inherit image_types_resin

# When building a Resin OS image, we also generate the kernel modules headers
# and ship them in the deploy directory for out-of-tree kernel modules build
DEPENDS += "kernel-modules-headers"

# Deploy the license.manifest of the current image we baked
deploy_image_license_manifest () {
    IMAGE_LICENSE_MANIFEST="${LICENSE_DIRECTORY}/${IMAGE_NAME}/license.manifest"
    # XXX support for post morty yocto versions
    # Check if we are running on a poky version which deploys to IMGDEPLOYDIR instead
    # of DEPLOY_DIR_IMAGE (poky morty introduced this change)
    if [ -d "${IMGDEPLOYDIR}" ]; then
        DEPLOY_IMAGE_LICENSE_MANIFEST="${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.license.manifest"
        DEPLOY_SYMLINK_IMAGE_LICENSE_MANIFEST="${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.license.manifest"
    else
        DEPLOY_IMAGE_LICENSE_MANIFEST="${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.license.manifest"
        DEPLOY_SYMLINK_IMAGE_LICENSE_MANIFEST="${DEPLOY_DIR_IMAGE}/${IMAGE_LINK_NAME}.license.manifest"
    fi
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

# Initialize config.json
# Requires 1 argument: Path to destination of config.json
init_config_json() {
   if [ -z ${1} ]; then
       bbfatal "init_config_json: Needs one argument, that has to be a path"
   fi

   echo '{}' > ${1}/config.json

   # Default no to persistent-logging
   echo $(cat ${1}/config.json | jq ".persistentLogging=false") > ${1}/config.json

   if ${@bb.utils.contains('DISTRO_FEATURES','development-image','true','false',d)}; then
       echo $(cat ${1}/config.json | jq ".hostname=\"resin\"") > ${1}/config.json
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

# We generate the host keys in /etc/dropbear
read_only_rootfs_hook_append () {
    sed -i -e "s:^DROPBEAR_RSAKEY_DIR=.*$:DROPBEAR_RSAKEY_DIR=/etc/dropbear:" ${IMAGE_ROOTFS}/etc/default/dropbear
}

# Generate the boot partition directory and deploy it to rootfs
resin_boot_dirgen_and_deploy () {
    echo "Generating work directory for resin-boot partition..."
    rm -rf ${RESIN_BOOT_WORKDIR}
    for RESIN_BOOT_PARTITION_FILE in ${RESIN_BOOT_PARTITION_FILES}; do
        echo "Handling $RESIN_BOOT_PARTITION_FILE ."

        # Check for item format
        case $RESIN_BOOT_PARTITION_FILE in
            *:*) ;;
            *) bbfatal "Some items in RESIN_BOOT_PARTITION_FILES ($RESIN_BOOT_PARTITION_FILE) are not in the 'src:dst' format."
        esac

        # Compute src and dst
        src="$(echo ${RESIN_BOOT_PARTITION_FILE} | awk -F: '{print $1}')"
        dst="$(echo ${RESIN_BOOT_PARTITION_FILE} | awk -F: '{print $2}')"
        if [ -z "${dst}" ]; then
            dst="/${src}" # dst was omitted
        fi
        src="${DEPLOY_DIR_IMAGE}/$src" # src is relative to deploy dir

        # Check that dst is an absolute path and assess if it should be a directory
        case $dst in
            /*)
                # Check if dst is a directory. Directory path ends with '/'.
                case $dst in
                    */) dst_is_dir=true ;;
                     *) dst_is_dir=false ;;
                esac
                ;;
             *) bbfatal "$dst in RESIN_BOOT_PARTITION_FILES is not an absolute path."
        esac

        # Check src type and existence
        if [ -d "$src" ]; then
            if ! $dst_is_dir; then
                bbfatal "You can't copy a directory to a file. You requested to copy $src in $dst."
            fi
            sources="$(find $src -maxdepth 1 -type f)"
        elif [ -f "$src" ]; then
            sources="$src"
        else
            bbfatal "$src is an invalid path referenced in RESIN_BOOT_PARTITION_FILES."
        fi

        # Normalize paths
        dst=$(realpath -ms $dst)
        if $dst_is_dir && [ ! "$dst" = "/" ]; then
            dst="$dst/" # realpath removes last '/' which we need to instruct mcopy that destination is a directory
        fi
        src=$(realpath -m $src)

        for src in $sources; do
            echo "Copying $src -> $dst ..."
            # Create the directories parent directories in dst
            directory=""
            for path_segment in $(echo ${RESIN_BOOT_WORKDIR}/${dst} | sed 's|/|\n|g' | head -n -1); do
                if [ -z "$path_segment" ]; then
                    continue
                fi
                directory=$directory/$path_segment
                mkdir -p $directory
            done
            cp -rvfL $src ${RESIN_BOOT_WORKDIR}/$dst
        done
    done
    echo "${IMAGE_NAME}" > ${RESIN_BOOT_WORKDIR}/image-version-info
    init_config_json ${RESIN_BOOT_WORKDIR}

    # Keep this after everything is ready in the resin-boot directory
    find ${RESIN_BOOT_WORKDIR} -xdev -type f \
        ! -name ${RESIN_FINGERPRINT_FILENAME}.${RESIN_FINGERPRINT_EXT} \
        ! -name config.json \
        -exec md5sum {} \; | sed "s#${RESIN_BOOT_WORKDIR}##g" | \
        sort -k2 > ${RESIN_BOOT_WORKDIR}/${RESIN_FINGERPRINT_FILENAME}.${RESIN_FINGERPRINT_EXT}

    echo "Install resin-boot in the rootfs..."
    cp -rvf ${RESIN_BOOT_WORKDIR} ${IMAGE_ROOTFS}/${RESIN_BOOT_FS_LABEL}
}

QUIRK_FILES ?= " \
    etc/hostname \
    etc/hosts \
    etc/resolv.conf \
    etc/mtab \
    "
resin_root_quirks () {
    # Quirks
    # We need to save some files that docker shadows with bind mounts
    # https://docs.docker.com/engine/userguide/networking/default_network/configure-dns/
    # Make sure you run this before packing
    if [ "${QUIRK_FILES}" != "" ];then
        for file in ${QUIRK_FILES}; do
            src="${IMAGE_ROOTFS}/$file"
            dst="${IMAGE_ROOTFS}/quirks/$file"
            if [ -f "$src" ] || [ -L "$src" ]; then
                mkdir -p $(dirname "$dst")
                cp -d "$src" "$dst"
            else
                bbfatal "Quirks: $src doesn't exist."
            fi
        done
    fi
}

resinhup_backwards_compatible_link () {
    if [ -d "${IMGDEPLOYDIR}" ]; then
        # Check if we are running on a poky version which deploys to IMGDEPLOYDIR instead
        # of DEPLOY_DIR_IMAGE (poky morty introduced this change)
        DEPLOY_IMAGE_TAR="${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.tar"
        RESIN_HUP_BUNDLE="${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.resinhup-tar"
    else
        IMAGE_NAME_SUFFIX=".rootfs"
        DEPLOY_IMAGE_TAR="${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.tar"
        RESIN_HUP_BUNDLE="${DEPLOY_DIR_IMAGE}/${IMAGE_LINK_NAME}.resinhup-tar"
    fi
    if [ -f ${DEPLOY_IMAGE_TAR} ]; then
        ln -fsv ${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.tar ${RESIN_HUP_BUNDLE}
    fi
}

add_image_flag_file () {
    echo "DO NOT REMOVE THIS FILE" > ${DEPLOY_DIR_IMAGE}/${RESIN_FLAG_FILE}
}

ROOTFS_POSTPROCESS_COMMAND += " \
    generate_compressed_kernel_module_deps ; \
    add_image_flag_file ; \
    resin_boot_dirgen_and_deploy ; \
    resin_root_quirks ; \
    "
IMAGE_POSTPROCESS_COMMAND =+ " \
    deploy_image_license_manifest ; \
    fix_hddimg_symlink ; \
    resinhup_backwards_compatible_link ; \
    "
IMAGE_PREPROCESS_COMMAND += "remove_backup_files ; "
