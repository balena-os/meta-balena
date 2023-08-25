SECTION = "kernel"
DESCRIPTION = "Linux initramfs bundled kernel packager"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PACKAGES = "${PN}"
FILES:${PN} = "/boot"

do_install() {
    mkdir -p ${D}/boot
    for type in ${KERNEL_IMAGETYPE}; do
        install -m 0644 ${DEPLOY_DIR_IMAGE}/${type}-initramfs-${MACHINE}.bin ${D}/boot/${type}
        if [ -f "${DEPLOY_DIR_IMAGE}/${type}.initramfs.sig" ]; then
            install -m 0644 ${DEPLOY_DIR_IMAGE}/${type}.initramfs ${D}/boot/${type}
            install -m 0644 "${DEPLOY_DIR_IMAGE}/${type}.initramfs.sig" "${D}/boot/${type}.sig"
        fi
    done
    for dtbf in ${KERNEL_DEVICETREE}; do
        dtb_ext=${dtbf##*.}
            if [ "${dtb_ext}" = "dtb" ]; then
                dtb_base_name=$(basename $dtbf)
                if [ -e ${DEPLOY_DIR_IMAGE}/${dtb_base_name} ]; then
                    install -m 0644 ${DEPLOY_DIR_IMAGE}/${dtb_base_name} ${D}/boot
                fi
            fi
    done
}
do_install[depends] += "virtual/kernel:do_deploy"

PACKAGE_ARCH = "${MACHINE_ARCH}"
