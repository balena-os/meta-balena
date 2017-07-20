FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"
SRC_URI_append = " \
    file://unprotected_wifi_tether.patch \
    file://write_dns_to_resolv.dnsmasq.patch \
    "
