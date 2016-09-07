SUMMARY = "Resin systemd mount services"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://mnt-boot.mount \
    file://mnt-conf.mount \
    file://mnt-data.mount \
    "

S = "${WORKDIR}"

inherit systemd allarch

PACKAGES = "${PN}"

SYSTEMD_SERVICE_${PN} = " \
    mnt-boot.mount \
    mnt-conf.mount \
    mnt-data.mount \
    "

FILES_${PN} += " \
    /mnt/data \
    /mnt/conf \
    /mnt/boot \
    "

do_install () {
    install -d ${D}/mnt/conf
    install -d ${D}/mnt/data
    install -d ${D}/mnt/boot

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 \
            ${WORKDIR}/mnt-boot.mount \
            ${WORKDIR}/mnt-conf.mount \
            ${WORKDIR}/mnt-data.mount \
            ${D}${systemd_unitdir}/system
    fi
}
