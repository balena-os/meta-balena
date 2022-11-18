inherit deploy

FILESEXTRAPATHS:append := ":${THISDIR}/balena-files:${THISDIR}/${BPN}"

SRC_URI:append = " \
    file://NetworkManager.conf.systemd \
    file://NetworkManager.conf \
    file://98dhcp_ntp \
    file://99onoffline_ntp \
    file://README.ignore \
    file://balena-sample.ignore \
    file://nm-tmpfiles.conf \
    file://remove-https-warning.patch \
    "

RDEPENDS:${PN}:append = " \
    bash \
    chrony \
    chronyc \
    balena-net-config \
    resolvconf \
    "
FILES:${PN}:append = " ${sysconfdir}/*"

EXTRA_OEMESON += " \
    -Dpolkit=false \
    -Dresolvconf=/sbin/resolvconf \
    -Dovs=false \
    "
PACKAGECONFIG:append = " modemmanager ppp"

# The external DHCP client doesn't work well with our `ipv4.dhcp-timeout`
# configuration. Switch to the internal one.
PACKAGECONFIG:remove = "dhclient"
EXTRA_OEMESON += " \
	-Ddhclient=false \
	"

PACKAGECONFIG:remove = "vala"
EXTRA_OEMESON += " \
    -Dvapi=false \
    -Dintrospection=false \
    -Dfirewalld_zone=false \
    "

do_install:append() {
    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 0644 ${WORKDIR}/nm-tmpfiles.conf ${D}${sysconfdir}/tmpfiles.d/

    install -m 0644 ${WORKDIR}/NetworkManager.conf ${D}${sysconfdir}/NetworkManager/
    mkdir -p "${D}${sysconfdir}/NetworkManager/dispatcher.d/"
    install -m 0755 ${WORKDIR}/98dhcp_ntp ${D}${sysconfdir}/NetworkManager/dispatcher.d/
    install -m 0755 ${WORKDIR}/99onoffline_ntp ${D}${sysconfdir}/NetworkManager/dispatcher.d/

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
    install -m 0600 "${WORKDIR}/balena-sample.ignore" "${DEPLOYDIR}/system-connections/"
    install -m 0600 "${WORKDIR}/README.ignore" "${DEPLOYDIR}/system-connections/"
}
addtask deploy before do_package after do_install
