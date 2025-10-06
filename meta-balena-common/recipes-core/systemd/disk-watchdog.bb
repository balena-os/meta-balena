SUMMARY = "Disk watchdog service for monitoring disk health"
DESCRIPTION = "A watchdog service that monitors disk health and takes action on failures"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = "git://github.com/balena-os/disk-watchdogd.git;branch=add-flowzone;protocol=https"
SRCREV = "f406edede6f3f1d013c0af7e8021b5634ba125fe"

SRC_URI += "file://disk-watchdogd.service"

S = "${WORKDIR}/git"

WD_TEST_FILE ?= "${bindir}/disk-watchdogd"

DEPENDS += "systemd"
RDEPENDS:${PN} += "systemd"

do_compile() {
    oe_runmake all
}

inherit systemd

SYSTEMD_SERVICE:${PN} = "disk-watchdogd.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 disk-watchdogd ${D}${bindir}/

    # Substitute paths in service file
    sed -i -e 's|@DAEMON_PATH@|/usr/bin/disk-watchdogd|g' \
           -e 's|@WD_TEST_FILE@|${WD_TEST_FILE}|g' \
           ${WORKDIR}/disk-watchdogd.service

    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/disk-watchdogd.service ${D}${systemd_unitdir}/system/
}
