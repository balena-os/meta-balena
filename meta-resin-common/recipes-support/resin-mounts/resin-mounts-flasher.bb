SUMMARY = "Resin flasher systemd mount services"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://mnt-boot.mount \
    file://mnt-bootorig-config.json.mount \
    file://temp-conf.service \
    file://mnt-bootorig.mount \
    "

S = "${WORKDIR}"

inherit systemd allarch

PACKAGES = "${PN}"

SYSTEMD_SERVICE_${PN} = " \
    mnt-boot.mount \
    mnt-bootorig-config.json.mount \
    temp-conf.service \
    mnt-bootorig.mount \
    "

FILES_${PN} += " \
    /mnt/conf \
    /mnt/boot \
    /mnt/bootorig \
    "

do_install () {
    install -d ${D}/mnt/conf
    install -d ${D}/mnt/boot
    install -d ${D}/mnt/bootorig

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${sysconfdir}/systemd/system
        install -c -m 0644 \
            ${WORKDIR}/mnt-boot.mount \
            ${WORKDIR}/mnt-bootorig-config.json.mount \
            ${WORKDIR}/temp-conf.service \
            ${WORKDIR}/mnt-bootorig.mount \
            ${D}${sysconfdir}/systemd/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@SBINDIR@,${sbindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            ${D}${sysconfdir}/systemd/system/*
    fi
}
