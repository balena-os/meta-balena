DESCRIPTION = "Periodic vacuum of log files"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://periodic-vacuum-logs.timer \
    file://periodic-vacuum-logs.service \
    "

inherit allarch systemd

SYSTEMD_SERVICE_${PN} = " \
    periodic-vacuum-logs.service \
    periodic-vacuum-logs.timer \
"

do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_build[noexec] = "1"

do_install() {
        install -d ${D}${systemd_unitdir}/system/
        install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants/
        install -m 0644 ${WORKDIR}/periodic-vacuum-logs.service ${D}${systemd_unitdir}/system/
        install -m 0644 ${WORKDIR}/periodic-vacuum-logs.timer ${D}${systemd_unitdir}/system/
}
