SECTION = "kernel"
DESCRIPTION = "Linux initramfs bundled kernel packager"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PACKAGES = "${PN}"
FILES_${PN} = "/boot"

do_install() {
    mkdir -p ${D}/boot
    for type in ${KERNEL_IMAGETYPE}; do
        install -m 0644 ${DEPLOY_DIR_IMAGE}/${type}-initramfs-${MACHINE}.bin ${D}/boot/${type}
    done
}
do_install[depends] += "virtual/kernel:do_deploy"

PACKAGE_ARCH = "${MACHINE_ARCH}"
