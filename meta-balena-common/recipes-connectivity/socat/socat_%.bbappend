FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " file://socat-mdns.service"

FILES_${PN} += " \
    ${systemd_unitdir}/system/socat-mdns.service \
"

SYSTEMD_SERVICE_${PN} += " socat-mdns.service"

do_install_append() {
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/socat-mdns.service ${D}${systemd_unitdir}/system
        sed -i -e 's,@BINDIR@,${bindir},g' \
            ${D}${systemd_unitdir}/system/*.service
    fi
}
