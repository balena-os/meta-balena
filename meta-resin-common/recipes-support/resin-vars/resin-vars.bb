DESCRIPTION = "Resin Configuration Recipe"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://resin-vars \
    file://config-json.path \
    file://config-json.service \
    file://os-networkmanager \
    file://os-networkmanager.service \
    file://os-udevrules \
    file://os-udevrules.service \
    file://os-sshkeys \
    file://os-sshkeys.service \
    "
S = "${WORKDIR}"

inherit allarch systemd

FILES_${PN} = "${sbindir}"

RDEPENDS_${PN} = "bash jq udev coreutils"

do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_build[noexec] = "1"

SYSTEMD_SERVICE_${PN} = " \
    config-json.path \
    config-json.service \
    os-networkmanager.service \
    os-udevrules.service \
    os-sshkeys.service \
    "

do_install() {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/resin-vars ${D}${sbindir}/
    install -m 0755 ${WORKDIR}/os-networkmanager ${D}${sbindir}/
    install -m 0755 ${WORKDIR}/os-udevrules ${D}${sbindir}/
    install -m 0755 ${WORKDIR}/os-sshkeys ${D}${sbindir}/

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/config-json.path ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/config-json.service ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/os-networkmanager.service ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/os-udevrules.service ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/os-sshkeys.service ${D}${systemd_unitdir}/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@SBINDIR@,${sbindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            ${D}${systemd_unitdir}/system/*.service
    fi
}
