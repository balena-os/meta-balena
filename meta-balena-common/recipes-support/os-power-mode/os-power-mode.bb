DESCRIPTION = "OS power mode management"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://os-power-mode \
    file://os-power-mode.service \
    "

S = "${WORKDIR}"

RDEPENDS:${PN} += "balena-config-vars bash"

inherit allarch systemd balena-configurable

SYSTEMD_SERVICE:${PN} = " \
    os-power-mode.service \
    "

do_patch[noexec] = "1"
do_compile[noexec] = "1"
do_build[noexec] = "1"

do_install() {
    install -d ${D}${bindir}/
    install -m 0755 ${WORKDIR}/os-power-mode ${D}${bindir}/

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system/
        install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants/
        install -m 0644 ${WORKDIR}/os-power-mode.service ${D}${systemd_unitdir}/system/

        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            ${D}${systemd_unitdir}/system/*.service
    fi
}