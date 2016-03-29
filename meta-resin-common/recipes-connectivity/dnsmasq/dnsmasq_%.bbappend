FILESEXTRAPATHS_append := ":${THISDIR}/files"

SRC_URI_append = " \
    file://0001-Treat-REFUSED-not-SERVFAIL-as-an-unsuccessful-upstre.patch \
    file://dnsmasq.conf.systemd \
    file://resolv.conf \
    "

do_install_append() {
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${sysconfdir}/systemd/system/dnsmasq.service.d
        install -c -m 0644 ${WORKDIR}/dnsmasq.conf.systemd ${D}${sysconfdir}/systemd/system/dnsmasq.service.d/dnsmasq.conf
        install -c -m 0644 ${WORKDIR}/resolv.conf ${D}${sysconfdir}
    fi
}
