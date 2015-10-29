FILESEXTRAPATHS_append := "${THISDIR}/${PN}:"

SRC_URI_append = " \
    file://ca.crt \
    file://resin.conf \
    file://prepare-openvpn \
    file://prepare-openvpn.service \
    file://openvpn-resin.service \
    file://upscript.sh \
    file://downscript.sh \
    "

# Fix DNS issues
SRC_URI_append = " \
    file://0001-fix-res-init-detection.patch \
    file://0002-Move-res_init-call-to-inner-openvpn_getaddrinfo-loop.patch \
    "

RDEPENDS_${PN} += "bash jq"

SYSTEMD_SERVICE_${PN} = " \
    openvpn-resin.service \
    prepare-openvpn.service \
    "
SYSTEMD_AUTO_ENABLE = "enable"

do_install_append() {
    install -d ${D}${sysconfdir}/openvpn
    install -m 0755 ${WORKDIR}/resin.conf ${D}${sysconfdir}/openvpn/resin.conf
    install -m 0755 ${WORKDIR}/upscript.sh ${D}${sysconfdir}/openvpn/upscript.sh
    install -m 0755 ${WORKDIR}/downscript.sh ${D}${sysconfdir}/openvpn/downscript.sh
    install -m 0755 ${WORKDIR}/ca.crt ${D}${sysconfdir}/openvpn/ca.crt

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${bindir}
        install -m 0755 ${WORKDIR}/prepare-openvpn ${D}${bindir}
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/prepare-openvpn.service ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/openvpn-resin.service ${D}${systemd_unitdir}/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@SBINDIR@,${sbindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            ${D}${systemd_unitdir}/system/*.service
    fi
}
do_install[vardeps] += "DISTRO_FEATURES"
