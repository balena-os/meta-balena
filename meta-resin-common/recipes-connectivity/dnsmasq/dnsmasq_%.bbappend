FILESEXTRAPATHS_append := ":${THISDIR}/files"

SRC_URI_append = " \
    file://dnsmasq.conf \
    file://dnsmasq.conf.systemd \
    file://resolv.conf \
    "

# for dnsmasq versions older than 2.76 we need to still apply the following patch:
python() {
    packageVersion = d.getVar('PV', True)
    srcURI = d.getVar('SRC_URI', True)
    if packageVersion < '2.76':
        d.setVar('SRC_URI', srcURI + ' ' + 'file://0001-Treat-REFUSED-not-SERVFAIL-as-an-unsuccessful-upstre.patch')
}

do_install_append() {
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${sysconfdir}/systemd/system/dnsmasq.service.d
        install -c -m 0644 ${WORKDIR}/dnsmasq.conf.systemd ${D}${sysconfdir}/systemd/system/dnsmasq.service.d/dnsmasq.conf
        install -c -m 0644 ${WORKDIR}/resolv.conf ${D}${sysconfdir}
    fi
}
