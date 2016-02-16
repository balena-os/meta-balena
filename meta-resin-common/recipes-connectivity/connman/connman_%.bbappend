FILESEXTRAPATHS_append := "${THISDIR}/${PN}:"
SRC_URI_append = " \
    file://unprotected_wifi_tether.patch \
    "

PR = "${INC_PR}.4"

RDEPENDS_${PN}_append = " resin-connman-conf"

SYSTEMD_AUTO_ENABLE = "enable"

do_configure_append () {
    # Disable the dnsproxy for systemd unit files.
    sed -i "s/ExecStart=.*/& --nodnsproxy/" ${B}/src/connman.service

    # Disable the dnsproxy for the init script.
    sed -i "s/\$DAEMON/\$DAEMON --nodnsproxy/" ${WORKDIR}/connman

    # Adjust OOMscore to -1000 to disable OOM killing for connman daemon
    sed -i "/\[Service\]/a OOMScoreAdjust=-1000" ${B}/src/connman.service
}
