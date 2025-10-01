SUMMARY = "Disk watchdog service for monitoring disk health"
DESCRIPTION = "A watchdog service that monitors disk health"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = "git://github.com/balena-os/disk-watchdogd.git;branch=master;protocol=https"
SRCREV = "1060e49da45d9bfda3047856d66bdc7c6b8c1911"

SRC_URI += "file://disk-watchdogd.service \
            file://disk-watchdog-boot-history.service \
            file://disk-watchdog-boot-history"

S = "${WORKDIR}/git"

WD_TEST_FILE ?= "${bindir}/disk-watchdogd"
DISK_WD_BOOT_DIR ?= "/mnt/state/disk-watchdog"

DEPENDS += "systemd"
RDEPENDS:${PN} += "systemd"
RDEPENDS:${PN} += "os-helpers-fs bash"

do_compile() {
    oe_runmake all
}

inherit systemd

SYSTEMD_SERVICE:${PN} = "disk-watchdogd.service disk-watchdog-boot-history.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 disk-watchdogd ${D}${bindir}/

    # Substitute paths in service file
    sed -i -e 's|@DAEMON_PATH@|/usr/bin/disk-watchdogd|g' \
           -e 's|@WD_TEST_FILE@|${WD_TEST_FILE}|g' \
           -e 's|@OS_HELPERS_FS@|${libexecdir}/os-helpers-fs|g' \
           -e 's|@DISK_WD_BOOT_DIR@|${DISK_WD_BOOT_DIR}|g' \
           ${WORKDIR}/disk-watchdogd.service

    # Substitute paths in boot history script
    sed -i -e 's|@DISK_WD_BOOT_DIR@|${DISK_WD_BOOT_DIR}|g' \
           ${WORKDIR}/disk-watchdog-boot-history

    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/disk-watchdogd.service ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/disk-watchdog-boot-history.service ${D}${systemd_unitdir}/system/
    install -m 0755 ${WORKDIR}/disk-watchdog-boot-history ${D}${bindir}/
}
