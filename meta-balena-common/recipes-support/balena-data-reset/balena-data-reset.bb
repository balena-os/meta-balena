DESCRIPTION = "balena data reset"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://balena-data-reset \
    file://balena-data-reset.service \
    "
S = "${WORKDIR}"

inherit allarch systemd

RDEPENDS_${PN} = " \
    bash \
    coreutils \
    "

SYSTEMD_SERVICE_${PN} = "balena-data-reset.service"

do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_build[noexec] = "1"

BALENA_DATA_MOUNT_POINT = "/mnt/data"

do_install() {
    install -d ${D}${bindir}/
    install -m 0755 ${WORKDIR}/balena-data-reset ${D}${bindir}/

    sed -i -e 's,@BALENA_DATA_MP@,${BALENA_DATA_MOUNT_POINT},g' \
          ${D}${bindir}/balena-data-reset

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system/
        install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants/
        install -m 0644 ${WORKDIR}/balena-data-reset.service ${D}${systemd_unitdir}/system/

        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@SBINDIR@,${sbindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            -e 's,@BALENA_DATA_MP@,${BALENA_DATA_MOUNT_POINT},g' \
            ${D}${systemd_unitdir}/system/*.service
    fi
}
