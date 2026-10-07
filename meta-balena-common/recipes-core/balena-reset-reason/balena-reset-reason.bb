SUMMARY = "Report why the previous boot ended"
DESCRIPTION = "Logs the previous reset to the journal on every boot."
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = "file://balena-reset-reason \
           file://balena-reset-reason.service \
           "

RDEPENDS:${PN} = "os-helpers-logging systemd"

inherit systemd allarch

SYSTEMD_SERVICE:${PN} = "balena-reset-reason.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${UNPACKDIR}/balena-reset-reason ${D}${bindir}/

    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${UNPACKDIR}/balena-reset-reason.service ${D}${systemd_unitdir}/system/
}
