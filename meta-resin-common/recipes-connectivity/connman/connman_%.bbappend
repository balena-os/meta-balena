FILESEXTRAPATHS_append := "${THISDIR}/${PN}:"
SRC_URI_append = " \
    file://unprotected_wifi_tether.patch \
    file://unsecured_wifi.patch \
    "

PR = "${INC_PR}.4"

RDEPENDS_${PN}_append = " resin-connman-conf"

do_configure_append () {
    # Disable the dnsproxy for systemd unit files.
    sed -i "s/ExecStart=.*/& --nodnsproxy/" ${B}/src/connman.service

    # Disable the dnsproxy for the init script.
    sed -i "s/\$DAEMON/\$DAEMON --nodnsproxy/" ${WORKDIR}/connman
}
