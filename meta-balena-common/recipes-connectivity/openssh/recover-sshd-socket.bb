DESCRIPTION = "Periodic recovery of sshd.socket after burst protection triggers"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://recover-sshd-socket.timer \
    file://recover-sshd-socket.service \
    "

inherit allarch systemd

SYSTEMD_SERVICE:${PN} = " \
    recover-sshd-socket.service \
    recover-sshd-socket.timer \
"

do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_build[noexec] = "1"

do_install() {
        install -d ${D}${systemd_unitdir}/system/
        install -m 0644 ${WORKDIR}/recover-sshd-socket.service ${D}${systemd_unitdir}/system/
        install -m 0644 ${WORKDIR}/recover-sshd-socket.timer ${D}${systemd_unitdir}/system/
}
