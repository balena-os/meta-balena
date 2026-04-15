DESCRIPTION = "resin NTP configuration"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://balena-ntp-config \
    file://balena-ntp-config.service \
    "
S_UNPACK = "${@d.getVar('UNPACKDIR') or d.getVar('WORKDIR')}"

S = "${S_UNPACK}"

inherit allarch systemd balena-configurable

SYSTEMD_SERVICE:${PN} = "balena-ntp-config.service"
RDEPENDS:${PN} = "chrony chronyc"

do_install() {
    install -d ${D}${bindir}
    install -m 0775 ${S_UNPACK}/balena-ntp-config ${D}${bindir}/balena-ntp-config

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${S_UNPACK}/balena-ntp-config.service ${D}${systemd_unitdir}/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
        -e 's,@BINDIR@,${bindir},g' \
            ${D}${systemd_unitdir}/system/balena-ntp-config.service
    fi
}
