inherit deploy meson

FILESEXTRAPATHS:append := ":${THISDIR}/balena-files:${THISDIR}/${BPN}"

SRC_URI:append = " \
    file://NetworkManager.conf.systemd \
    file://NetworkManager.conf \
    file://90shared \
    file://98dhcp_ntp \
    file://99onoffline_ntp \
    file://README.ignore \
    file://balena-sample.ignore \
    file://nm-tmpfiles.conf \
    file://remove-https-warning.patch \
    "

NETWORKMANAGER_FIREWALL_DEFAULT = "iptables"

NETWORKMANAGER_DNS_RC_MANAGER_DEFAULT = "resolvconf"

RDEPENDS:${PN}:append = " \
    bash \
    chrony \
    chronyc \
    balena-net-config \
    resolvconf \
    os-helpers-logging \
    "
FILES:${PN}:append = " ${sysconfdir}/*"

EXTRA_OEMESON += " \
    -Dresolvconf=/sbin/resolvconf \
    -Dovs=false \
    "
PACKAGECONFIG:append = " modemmanager ppp resolvconf concheck"

# The external DHCP client doesn't work well with our `ipv4.dhcp-timeout`
# configuration. Switch to the internal one.
PACKAGECONFIG:remove = "dhclient"
EXTRA_OEMESON += " \
	-Ddhclient=false \
	"

PACKAGECONFIG:remove = "vala"
GNOMEBASEBUILDCLASS = "meson"
EXTRA_OEMESON += " \
    -Dvapi=false \
    -Dintrospection=false \
    -Dfirewalld_zone=false \
    "

# disable init script as we use systemd
INITSCRIPT_PACKAGES = ""
INITSCRIPT_NAME:${PN}-daemon = ""

do_install:append() {
    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 0644 ${WORKDIR}/nm-tmpfiles.conf ${D}${sysconfdir}/tmpfiles.d/

    install -m 0644 ${WORKDIR}/NetworkManager.conf ${D}${sysconfdir}/NetworkManager/

    # Install balena dispatch scripts in /usr/lib/NetworkManager/dispatcher.d/ as
    # /etc/NetworkManager/dispatcher.d/ is used for user-provided scripts
    install -m 0755 ${WORKDIR}/90shared ${D}${libdir}/NetworkManager/dispatcher.d/
    install -m 0755 ${WORKDIR}/98dhcp_ntp ${D}${libdir}/NetworkManager/dispatcher.d/
    install -m 0755 ${WORKDIR}/99onoffline_ntp ${D}${libdir}/NetworkManager/dispatcher.d/

    # Cleanup /etc/NetworkManager/dispatcher.d/, so that it is empty when bindmounted
    rm -rdf ${D}${sysconfdir}/NetworkManager/dispatcher.d/*

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
