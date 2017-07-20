FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"
SRC_URI_append = " \
    file://allow_more_than_MAXNS_nameserver_entries_in_the_resolv_file.patch \
    file://do_not_add_routes_to_nameservers.patch \
    "

PR = "${INC_PR}.4"

RDEPENDS_${PN}_append = " resin-connman-conf"

SYSTEMD_AUTO_ENABLE = "enable"
