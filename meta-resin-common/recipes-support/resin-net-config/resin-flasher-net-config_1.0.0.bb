DESCRIPTION = "resin flasher network management configuration addon"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r0"

SRC_URI = "file://resin-net-config.service"
S = "${WORKDIR}"

inherit allarch systemd

SYSTEMD_SERVICE_${PN} = "resin-net-config.service"
RDEPENDS_${PN} = "resin-net-config"

do_install() {
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${sysconfdir}/systemd/system
        install -c -m 0644 ${WORKDIR}/resin-net-config.service ${D}${sysconfdir}/systemd/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
        -e 's,@BINDIR@,${bindir},g' \
            ${D}${sysconfdir}/systemd/system/resin-net-config.service
    fi
}
