LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PROVIDES = "rce"
RPROVIDES_${PN} = "rce"

SRC_URI_append = " \
    file://prepare-rce \
    file://prepare-rce.service \
    file://rce.service \
    file://rce.socket \
    "

inherit systemd

SYSTEMD_SERVICE_${PN} = "prepare-rce.service rce.service rce.socket"

FILES_${PN} += "/.rce /mnt"

RDEPENDS_${PN} = "bash ca-certificates"

do_install() {
    install -d ${D}${bindir}
    install -d ${D}/.rce
    install -d ${D}/mnt/data/rce
    mkdir -p ${D}${localstatedir}/lib/rce
    install  -m 0755 ${S}/rce ${D}${bindir}
    install  -m 0755 ${WORKDIR}/prepare-rce ${D}${bindir}

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/prepare-rce.service ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/rce.service ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/rce.socket ${D}${systemd_unitdir}/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@SBINDIR@,${sbindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            ${D}${systemd_unitdir}/system/*.service
    fi
}
