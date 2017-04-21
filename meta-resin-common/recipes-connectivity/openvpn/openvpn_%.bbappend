inherit deploy

FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"

RESIN_CONNECTABLE_SRCURI = " \
    file://ca.crt \
    file://prepare-openvpn \
    file://prepare-openvpn.service \
    file://resin-vpn \
    "
SRC_URI_append = " ${@bb.utils.contains("RESIN_CONNECTABLE","1","${RESIN_CONNECTABLE_SRCURI}","",d)}"

RDEPENDS_${PN} += "${@bb.utils.contains("RESIN_CONNECTABLE","1","bash jq resin-device-uuid sed","",d)}"

SYSTEMD_SERVICE_${PN} = "${@bb.utils.contains("RESIN_CONNECTABLE","1","prepare-openvpn.service","",d)}"

do_install_append() {
    if [ ${RESIN_CONNECTABLE} -eq 1 ]; then
        install -d ${D}${sysconfdir}/openvpn
        install -m 0755 ${WORKDIR}/ca.crt ${D}${sysconfdir}/openvpn/ca.crt

        if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
            install -d ${D}${bindir}
            install -m 0755 ${WORKDIR}/prepare-openvpn ${D}${bindir}
            install -d ${D}${systemd_unitdir}/system
            install -c -m 0644 ${WORKDIR}/prepare-openvpn.service ${D}${systemd_unitdir}/system
            sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
                -e 's,@SBINDIR@,${sbindir},g' \
                -e 's,@BINDIR@,${bindir},g' \
                ${D}${systemd_unitdir}/system/*.service
        fi
    fi
}
do_install[vardeps] += "DISTRO_FEATURES RESIN_CONNECTABLE"

do_deploy() {
    mkdir -p "${DEPLOYDIR}/system-connections/"
    install -m 0600 "${WORKDIR}/resin-vpn" "${DEPLOYDIR}/system-connections/"
}

addtask deploy before do_package after do_install
