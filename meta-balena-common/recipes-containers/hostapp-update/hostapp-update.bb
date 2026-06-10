DESCRIPTION = "Resin hostapp updater"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
	file://hostapp-update \
	file://hostapp-update@.service \
	"
S = "${WORKDIR}"

inherit allarch

BBCLASSEXTEND = "native"

FILES:${PN} = " \
    ${bindir} \
    ${systemd_unitdir}/system \
    "

RDEPENDS:${PN} += " \
    balena \
    "

RDEPENDS:${PN}:class-target += " \
    systemd \
    os-helpers-reboot \
    "

do_install() {
    install -d ${D}${bindir}
    install -d ${D}${systemd_unitdir}/system
    install -m 0755 ${WORKDIR}/hostapp-update ${D}${bindir}
    install -m 0644 ${WORKDIR}/hostapp-update@.service ${D}${systemd_unitdir}/system
}
