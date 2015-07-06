DESCRIPTION = "Resin BTRFS balance"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://resin-btrfs-balance \
    file://resin-btrfs-balance.service \
    file://resin-btrfs-balance.timer \
    "
S = "${WORKDIR}"

inherit allarch systemd

SYSTEMD_SERVICE_${PN} = " \
    resin-btrfs-balance.service \
    resin-btrfs-balance.timer \
    "

RDEPENDS_${PN} = " \
    bash \
    btrfs-tools \
    "

do_install() {
    install -d ${D}${bindir}
    install -m 0775 ${WORKDIR}/resin-btrfs-balance ${D}${bindir}

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/resin-btrfs-balance.service ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/resin-btrfs-balance.timer ${D}${systemd_unitdir}/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@SBINDIR@,${sbindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            ${D}${systemd_unitdir}/system/*.service
    fi
}
