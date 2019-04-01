FILESEXTRAPATHS_prepend := "${THISDIR}/balena-files:"

SRC_URI += " \
	file://dnsmasq.conf.systemd \
	file://resolv-conf.dnsmasq \
"

inherit update-alternatives

do_install_append () {
	if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
		install -d ${D}${sysconfdir}/systemd/system/dnsmasq.service.d
		install -c -m 0644 ${WORKDIR}/dnsmasq.conf.systemd ${D}${sysconfdir}/systemd/system/dnsmasq.service.d/dnsmasq.conf
		install -c -m 0644 ${WORKDIR}/resolv-conf.dnsmasq ${D}${sysconfdir}
	fi
}

ALTERNATIVE_${PN} = "resolv-conf"
ALTERNATIVE_TARGET[resolv-conf] = "${sysconfdir}/resolv-conf.dnsmasq"
ALTERNATIVE_LINK_NAME[resolv-conf] = "${sysconfdir}/resolv.conf"
ALTERNATIVE_PRIORITY[resolv-conf] = "60"

PACKAGECONFIG_append = "dbus"
