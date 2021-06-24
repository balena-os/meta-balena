DESCRIPTION = "resin proxy configuration"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://redsocks.service \
    file://balena-proxy-config \
    file://balena-proxy-config.service \
    "
S = "${WORKDIR}"

inherit allarch systemd useradd

PACKAGES = "${PN}"

SYSTEMD_SERVICE_${PN} = "balena-proxy-config.service redsocks.service"
RDEPENDS_${PN} = "redsocks iptables"

USERADD_PACKAGES = "${PN}"
USERADD_PARAM_${PN} += "--system redsocks"

do_install() {
    install -d ${D}${bindir}
    install -m 0775 ${WORKDIR}/balena-proxy-config ${D}${bindir}/balena-proxy-config

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/balena-proxy-config.service ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/redsocks.service ${D}${systemd_unitdir}/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            ${D}${systemd_unitdir}/system/*.service
    fi
}
