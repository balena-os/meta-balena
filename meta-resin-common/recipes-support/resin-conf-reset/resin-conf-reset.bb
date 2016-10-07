DESCRIPTION = "Resin conf reset"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://resin-conf-reset \
    file://resin-conf-reset.service \
    "
S = "${WORKDIR}"

inherit allarch systemd

RDEPENDS_${PN} = " \
    bash \
    coreutils \
    "

SYSTEMD_SERVICE_${PN} = "resin-conf-reset.service"

do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_build[noexec] = "1"

RESIN_CONF_MOUNT_POINT = "/mnt/conf"

do_install() {
    install -d ${D}${bindir}/
    install -m 0755 ${WORKDIR}/resin-conf-reset ${D}${bindir}/

    sed -i -e 's,@RESIN_CONF_MP@,${RESIN_CONF_MOUNT_POINT},g' \
          ${D}${bindir}/resin-conf-reset

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system/
        install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants/
        install -m 0644 ${WORKDIR}/resin-conf-reset.service ${D}${systemd_unitdir}/system/

        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@SBINDIR@,${sbindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            -e 's,@RESIN_CONF_MP@,${RESIN_CONF_MOUNT_POINT},g' \
            ${D}${systemd_unitdir}/system/*.service
    fi
}
