DESCRIPTION = "balena full network connectivity checker"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://balena-net-connectivity-wait \
    file://balena-net-connectivity-wait.service \
    file://balena-net-connectivity-wait.target \
    "
S = "${WORKDIR}"

inherit allarch systemd

PACKAGES = "${PN}"

SYSTEMD_SERVICE:${PN} = " \
	balena-net-connectivity-wait.service \
	balena-net-connectivity-wait.target \
	"
RDEPENDS:${PN} = "bash"

do_install() {
    install -d ${D}${bindir}
    install -m 0775 ${WORKDIR}/balena-net-connectivity-wait ${D}${bindir}/balena-net-connectivity-wait

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/balena-net-connectivity-wait.service ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/balena-net-connectivity-wait.target ${D}${systemd_unitdir}/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
        -e 's,@BINDIR@,${bindir},g' \
            ${D}${systemd_unitdir}/system/balena-net-connectivity-wait.service
    fi
}
