inherit deploy

FILESEXTRAPATHS_append := ":${THISDIR}/resin-files"

SRC_URI_append = " \
    file://NetworkManager.conf.systemd \
    file://NetworkManager.conf \
    file://99dhcp_ntp \
    file://README.ignore \
    file://resin-sample.ignore \
    file://nm-tmpfiles.conf \
    file://balena-client-id.patch \
    file://remove-https-warning.patch \
    "

RDEPENDS_${PN}_append = " \
    chrony \
    chronyc \
    resin-net-config \
    resolvconf \
    "
FILES_${PN}_append = " ${sysconfdir}/*"

EXTRA_OECONF += " \
    --with-resolvconf=/sbin/resolvconf \
    --disable-ovs \
    "
PACKAGECONFIG_append = " modemmanager ppp"

# The external DHCP client doesn't work well with our `ipv4.dhcp-timeout`
# configuration. Switch to the internal one.
PACKAGECONFIG_remove = "dhclient"
EXTRA_OECONF += " \
	--with-config-dhcp-default=internal \
	--with-dhclient=no \
	"

do_install_append() {
    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 0644 ${WORKDIR}/nm-tmpfiles.conf ${D}${sysconfdir}/tmpfiles.d/

    install -m 0644 ${WORKDIR}/NetworkManager.conf ${D}${sysconfdir}/NetworkManager/
    mkdir -p "${D}${sysconfdir}/NetworkManager/dispatcher.d/"
    install -m 0755 ${WORKDIR}/99dhcp_ntp ${D}${sysconfdir}/NetworkManager/dispatcher.d/

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${sysconfdir}/systemd/system/NetworkManager.service.d
        install -m 0644 ${WORKDIR}/NetworkManager.conf.systemd ${D}${sysconfdir}/systemd/system/NetworkManager.service.d/NetworkManager.conf
    fi

    ln -s /var/run/resolvconf/interface/NetworkManager ${D}/etc/resolv.dnsmasq

    # remove these empty not-used (at this moment) directories so we don't have to package them
    rmdir ${D}${libdir}/NetworkManager/conf.d
    rmdir ${D}${libdir}/NetworkManager/VPN
}

do_deploy() {
    mkdir -p "${DEPLOYDIR}/system-connections/"
    install -m 0600 "${WORKDIR}/resin-sample.ignore" "${DEPLOYDIR}/system-connections/"
    install -m 0600 "${WORKDIR}/README.ignore" "${DEPLOYDIR}/system-connections/"
}
addtask deploy before do_package after do_install
