FILESEXTRAPATHS_append := "${THISDIR}/${PN}:"
SRC_URI_append = " \
    file://unprotected_wifi_tether.patch \
    file://write_dns_to_resolv.dnsmasq.patch \
    file://allow_more_than_MAXNS_nameserver_entries_in_the_resolv_file.patch \
    "

PR = "${INC_PR}.4"

RDEPENDS_${PN}_append = " resin-connman-conf"

SYSTEMD_AUTO_ENABLE = "enable"
