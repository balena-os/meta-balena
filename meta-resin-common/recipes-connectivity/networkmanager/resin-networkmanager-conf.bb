SUMMARY = "Resin NetworkManager config"
DESCRIPTION = "This is the NetworkManager configuration to set up Resin"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = " \
    file://networkmanager.conf \
    "
S = "${WORKDIR}"

PR = "r0"

FILES_${PN} = "${sysconfdir}/*"
RDEPENDS_${PN} = "resin-net-config"

do_install() {
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${sysconfdir}/systemd/system/networkmanager.service.d
        install -c -m 0644 ${WORKDIR}/networkmanager.conf ${D}${sysconfdir}/systemd/system/networkmanager.service.d/
    fi

    #install -d ${D}${sysconfdir}/connman
    #install -m 0755 ${WORKDIR}/main.conf ${D}${sysconfdir}/connman/main.conf
}
