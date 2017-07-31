FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"
SRC_URI_append = " \
    file://remove-old-IP-and-gateway-address.patch \
    file://unprotected_wifi_tether.patch \
    file://write_dns_to_resolv.dnsmasq.patch \
    "
