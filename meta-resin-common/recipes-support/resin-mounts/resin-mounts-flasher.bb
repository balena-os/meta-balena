SUMMARY = "Resin flasher systemd mount services"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://boot.mount \
    file://mnt-conf.mount \
    file://mnt-conforig.mount \
    file://temp-conf.service \
    "

S = "${WORKDIR}"

inherit systemd allarch

PACKAGES = "${PN}"

SYSTEMD_SERVICE_${PN} = " \
    boot.mount \
    mnt-conf.mount \
    mnt-conforig.mount \
    temp-conf.service \
    "

do_install () {
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${sysconfdir}/systemd/system
        install -c -m 0644 \
            ${WORKDIR}/boot.mount \
            ${WORKDIR}/mnt-conf.mount \
            ${WORKDIR}/mnt-conforig.mount \
            ${WORKDIR}/temp-conf.service \
            ${D}${sysconfdir}/systemd/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@SBINDIR@,${sbindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            ${D}${sysconfdir}/systemd/system/*
    fi
}
