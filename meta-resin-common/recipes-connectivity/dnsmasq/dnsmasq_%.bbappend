FILESEXTRAPATHS_append := ":${THISDIR}/files"

# disable auto start; dnsmasq will be started by NetworkManager

SYSTEMD_AUTO_ENABLE = "disable"

SRC_URI_append = " \
    file://rce \
    "

do_install_append() {
        install -d ${D}${sysconfdir}/NetworkManager/dnsmasq.d
        install -c -m 0644 ${WORKDIR}/rce ${D}${sysconfdir}/NetworkManager/dnsmasq.d/
}
