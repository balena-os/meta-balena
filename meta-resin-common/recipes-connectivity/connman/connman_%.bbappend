FILESEXTRAPATHS_append := "${THISDIR}/${PN}:"
SRC_URI_append = " \
    file://unprotected_wifi_tether.patch \
    "

PR = "${INC_PR}.4"

RDEPENDS_${PN}_append = " resin-connman-conf"

SYSTEMD_AUTO_ENABLE = "enable"
