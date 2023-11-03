#
# Balena signed images support
#

IMAGE_SIGNED ?= "${BALENA_BOOT_FS}.sb"
IMAGE_SIGNATURE ?= "${IMAGE_SIGNED}.signature"

inherit sign-generic

do_balena_signed_bootgen_and_deploy() {
    set -x

    if [ -z "${BALENA_BOOT_FS}" ]; then
        bberror "No defined balena boot image - please use in the context of buildign a balenaos-img"
    fi
    if [ ! -d "${BALENA_BOOT_WORKDIR}" ]; then
        bberror "No defined balena boot directory - please use in the context of buildign a balenaos-img"
    fi
    if $(ls -A "${BALENA_BOOT_WORKDIR}"); then
        bberror "Empty balena boot directory"
    fi

    # Create a disk image from the contents of the boot directory
    block_size="${IMAGE_BLOCK_SIZE:-1024}"
    alignment="${BALENA_IMAGE_ALIGNMENT:-4096}"
    size=$(expr $(du -ks ${BALENA_BOOT_WORKDIR} | awk '{print $1}') \+ ${alignment})
    dd if=/dev/zero of="${IMAGE_SIGNED}" bs="${block_size}" count="${size}"
    mkfs.vfat "${IMAGE_SIGNED}" "${size}"
    mcopy -i "${IMAGE_SIGNED}" -svm ${BALENA_BOOT_WORKDIR}/* ::

    # Sign the boot disk image
    do_sign_generic

    # Erase the contents of the boot directory
    rm -rf ${BALENA_BOOT_WORKDIR}/*

    # Copy the signed boot disk image and signature to the boot partition
    cp -rf "${IMAGE_SIGNED}" "${IMAGE_SIGNATURE}" ${BALENA_BOOT_WORKDIR}/
}

do_balena_signed_bootgen_and_deploy[depends] += " \
    dosfstools-native:do_populate_sysroot \
    mtools-native:do_populate_sysroot \
"
addtask balena_signed_bootgen_and_deploy after do_resin_boot_dirgen_and_deploy  before do_image_complete
