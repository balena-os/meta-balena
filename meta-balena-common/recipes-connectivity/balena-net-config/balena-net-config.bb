DESCRIPTION = "resin network management configuration"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r1.1"

SRC_URI = " \
    file://balena-net-config \
    file://balena-net-config.service \
    "
S = "${WORKDIR}"

inherit allarch systemd

PACKAGES = "${PN} ${PN}-flasher"

SYSTEMD_SERVICE:${PN} = "balena-net-config.service"
RDEPENDS:${PN} = "bash jq iw"

do_install() {
    install -d ${D}${bindir}
    install -m 0775 ${WORKDIR}/balena-net-config ${D}${bindir}/balena-net-config

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/balena-net-config.service ${D}${systemd_unitdir}/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
        -e 's,@BINDIR@,${bindir},g' \
            ${D}${systemd_unitdir}/system/balena-net-config.service
    fi
}
