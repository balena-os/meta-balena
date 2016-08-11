RCONFLICTS_${PN}_remove = "connman"

FILESEXTRAPATHS_append := ":${THISDIR}/files"

SRC_URI_append = " \
    file://NetworkManager.conf \
    "

RDEPENDS_${PN}_append = " resin-networkmanager-conf"
SYSTEMD_AUTO_ENABLE = "disable"

do_install_append() {
    install -c -m 0644 ${WORKDIR}/NetworkManager.conf ${D}${sysconfdir}/NetworkManager/
}
