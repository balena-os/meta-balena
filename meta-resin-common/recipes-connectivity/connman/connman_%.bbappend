FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"
SRC_URI_append = " \
    file://allow_more_than_MAXNS_nameserver_entries_in_the_resolv_file.patch \
    file://do_not_add_routes_to_nameservers.patch \
    file://remove-old-IP-and-gateway-address.patch \
    "

# starting with connman version 1.32, the patch unprotected_wifi_tether.patch needs to be redone
# we work around this by detecting the connman version and applying the right patch for it
python() {
    packageVersion = d.getVar('PV', True)
    srcURI = d.getVar('SRC_URI', True)
    if packageVersion >= '1.32':
        d.setVar('SRC_URI', srcURI + ' ' + 'file://unprotected_wifi_tether_updated_for_morty.patch')
    else:
        d.setVar('SRC_URI', srcURI + ' ' + 'file://unprotected_wifi_tether.patch')
}

# starting with connman version 1.31, the patch write_dns_to_resolv.dnsmasq.patch needs to be redone
# we work around this by detecting the connman version and applying the right patch for it
python() {
    packageVersion = d.getVar('PV', True)
    srcURI = d.getVar('SRC_URI', True)
    if packageVersion >= '1.31':
        d.setVar('SRC_URI', srcURI + ' ' + 'file://write_dns_to_resolv.dnsmasq_updated_for_morty.patch')
    else:
        d.setVar('SRC_URI', srcURI + ' ' + 'file://write_dns_to_resolv.dnsmasq.patch')
}

PR = "${INC_PR}.4"

RDEPENDS_${PN}_append = " resin-connman-conf"

SYSTEMD_AUTO_ENABLE = "enable"
