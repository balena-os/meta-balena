require recipes-support/dnsmasq/dnsmasq.inc

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
    file://lua.patch \
    file://dnsmasq.conf.systemd \
    file://resolv.conf \
    "

SRC_URI[dnsmasq-2.78.md5sum] = "3bb97f264c73853f802bf70610150788"
SRC_URI[dnsmasq-2.78.sha256sum] = "c92e5d78aa6353354d02aabf74590d08980bb1385d8a00b80ef9bc80430aa1dc"

do_install_append() {
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${sysconfdir}/systemd/system/dnsmasq.service.d
        install -c -m 0644 ${WORKDIR}/dnsmasq.conf.systemd ${D}${sysconfdir}/systemd/system/dnsmasq.service.d/dnsmasq.conf
        install -c -m 0644 ${WORKDIR}/resolv.conf ${D}${sysconfdir}
    fi
}
