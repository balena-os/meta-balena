DESCRIPTION = "resin device register"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r2"

SRC_URI = " \
    file://resin-device-register \
    file://resin-device-register.service \
    "
S = "${WORKDIR}"

inherit allarch systemd

RDEPENDS_${PN} = " \
    bash \
    curl \
    jq \
    resin-vars \
    balena-unique-key \
    "

SYSTEMD_SERVICE_${PN} = "resin-device-register.service"

do_install() {
    install -d ${D}${bindir}
    install -m 0775 ${WORKDIR}/resin-device-register ${D}${bindir}

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/resin-device-register.service ${D}${systemd_unitdir}/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@SBINDIR@,${sbindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            ${D}${systemd_unitdir}/system/*.service
    fi
}
