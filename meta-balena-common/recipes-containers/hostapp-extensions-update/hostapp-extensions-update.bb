DESCRIPTION = "BalenaOS hostapp extensions updater"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
	file://update-hostapp-extensions \
	file://update-hostapp-extensions.service \
	"
S = "${WORKDIR}"

inherit allarch systemd

FILES_${PN} = "${bindir}"

RDEPENDS_${PN} = " \
    balena \
    resin-vars \
    "

SYSTEMD_SERVICE_${PN} = "update-hostapp-extensions.service"
SYSTEMD_AUTO_ENABLE = "disable"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/update-hostapp-extensions ${D}${bindir}

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/update-hostapp-extensions.service ${D}${systemd_unitdir}/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@SBINDIR@,${sbindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            ${D}${systemd_unitdir}/system/*.service
    fi
}
