DESCRIPTION = "Resin custom INIT file"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r6"

SRC_URI = " \
    file://resin-init \
    file://resin-init.service \
    "
S = "${WORKDIR}"

inherit update-rc.d allarch systemd

INITSCRIPT_NAME = "resin-init"
INITSCRIPT_PARAMS = "start 06 5 ."

SYSTEMD_SERVICE_${PN} = "resin-init.service"
FILES_${PN} = "${sysconfdir}/* ${base_sbindir}/*"

RDEPENDS_${PN} = " \
    resin-init-board \
    bash \
    connman \
    coreutils \
    util-linux \
    btrfs-tools \
    resin-device-register \
    resin-device-progress \
    mtools \
    resin-conf \
    openssl \
    connman \
    "

do_install() {
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${base_sbindir}
        install -m 0755 ${WORKDIR}/resin-init ${D}${base_sbindir}
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/resin-init.service ${D}${systemd_unitdir}/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@BASE_SBINDIR@,${base_sbindir},g' \
            -e 's,@SBINDIR@,${sbindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            -e 's,@SYS_CONFDIR@,${sysconfdir},g' \
            ${D}${systemd_unitdir}/system/resin-init.service
    fi

    if ${@bb.utils.contains('DISTRO_FEATURES','sysvinit','true','false',d)}; then
        install -d ${D}${sysconfdir}/init.d
        install -m 0755 ${WORKDIR}/resin-init ${D}${sysconfdir}/init.d

    fi
}
