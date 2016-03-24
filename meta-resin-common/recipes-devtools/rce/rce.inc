LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PROVIDES = "docker"
RPROVIDES_${PN} = "docker"

SRC_URI_append = " \
    file://renamed-rce.mount \
    file://var-lib-rce.mount \
    file://rce.service \
    file://rce.socket \
    "

inherit systemd

SYSTEMD_SERVICE_${PN} = "rce.service rce.socket"

FILES_${PN} += "/.rce /mnt ${systemd_unitdir}"

RDEPENDS_${PN} = "ca-certificates"

do_install() {
    install -d ${D}${bindir}
    install -d ${D}/.rce
    install -d ${D}/mnt/data/rce
    install -d ${D}${localstatedir}/lib/rce
    install -m 0755 ${S}/rce ${D}${bindir}

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/renamed-rce.mount ${D}${systemd_unitdir}/system/\\x2erce.mount
        install -c -m 0644 ${WORKDIR}/var-lib-rce.mount ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/rce.service ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/rce.socket ${D}${systemd_unitdir}/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@SBINDIR@,${sbindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            ${D}${systemd_unitdir}/system/*.service
    fi
}
