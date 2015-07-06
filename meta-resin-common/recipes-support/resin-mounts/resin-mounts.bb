SUMMARY = "Resin systemd mount services"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://boot.mount \
    file://mnt-conf.mount \
    file://mnt-data.mount \
    "

S = "${WORKDIR}"

inherit systemd allarch

PACKAGES = "${PN}"

SYSTEMD_SERVICE_${PN} = " \
    boot.mount \
    mnt-conf.mount \
    mnt-data.mount \
    "

do_install () {
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 \
            ${WORKDIR}/boot.mount \
            ${WORKDIR}/mnt-conf.mount \
            ${WORKDIR}/mnt-data.mount \
            ${D}${systemd_unitdir}/system
    fi
}
