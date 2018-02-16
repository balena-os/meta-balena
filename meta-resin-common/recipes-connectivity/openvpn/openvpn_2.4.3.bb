SUMMARY = "A full-featured SSL VPN solution via tun device."
HOMEPAGE = "http://openvpn.sourceforge.net"
SECTION = "net"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=e9b64491ec98eb6c6493ac5e4118f107"
DEPENDS = "lzo openssl iproute2 ${@bb.utils.contains('DISTRO_FEATURES', 'pam', 'libpam', '', d)}"

inherit autotools systemd

SRC_URI = "http://swupdate.openvpn.org/community/releases/${BP}.tar.gz \
           file://openvpn \
           file://openvpn@.service \
           file://openvpn-volatile.conf"

SRC_URI[md5sum] = "e1929f82aff40f3d105e5f72aacff9c1"
SRC_URI[sha256sum] = "cee3d3ca462960a50a67c0ebd186e01b6d13db70275205663695152c9aca8579"

SYSTEMD_SERVICE_${PN} += "openvpn@loopback-server.service openvpn@loopback-client.service"
SYSTEMD_AUTO_ENABLE = "disable"

CFLAGS += "-fno-inline"

# I want openvpn to be able to read password from file (hrw)
EXTRA_OECONF += "--enable-iproute2"
EXTRA_OECONF += "${@bb.utils.contains('DISTRO_FEATURES', 'pam', '', '--disable-plugin-auth-pam', d)}"

# Explicitly specify IPROUTE to bypass the configure-time check for /sbin/ip on the host.
EXTRA_OECONF += "IPROUTE=${base_sbindir}/ip"

do_install_append() {
    install -d ${D}/${sysconfdir}/init.d
    install -m 755 ${WORKDIR}/openvpn ${D}/${sysconfdir}/init.d

    install -d ${D}/${sysconfdir}/openvpn
    install -d ${D}/${sysconfdir}/openvpn/sample
    install -m 755 ${S}/sample/sample-config-files/loopback-server  ${D}${sysconfdir}/openvpn/sample/loopback-server.conf
    install -m 755 ${S}/sample/sample-config-files/loopback-client  ${D}${sysconfdir}/openvpn/sample/loopback-client.conf
    install -dm 755 ${D}${sysconfdir}/openvpn/sample/sample-keys
    install -m 644 ${S}/sample/sample-keys/* ${D}${sysconfdir}/openvpn/sample/sample-keys

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}/${systemd_unitdir}/system
        install -m 644 ${WORKDIR}/openvpn@.service ${D}/${systemd_unitdir}/system
        install -m 644 ${WORKDIR}/openvpn@.service ${D}/${systemd_unitdir}/system/openvpn@loopback-server.service
        install -m 644 ${WORKDIR}/openvpn@.service ${D}/${systemd_unitdir}/system/openvpn@loopback-client.service

        install -d ${D}/${localstatedir}
        install -d ${D}/${localstatedir}/lib
        install -d -m 710 ${D}/${localstatedir}/lib/openvpn

        install -d ${D}${sysconfdir}/tmpfiles.d
        install -m 0644 ${WORKDIR}/openvpn-volatile.conf ${D}${sysconfdir}/tmpfiles.d/openvpn.conf
        sed -i -e 's#@LOCALSTATEDIR@#${localstatedir}#g' ${D}${sysconfdir}/tmpfiles.d/openvpn.conf
    fi
}

PACKAGES =+ " ${PN}-sample "

RRECOMMENDS_${PN} = "kernel-module-tun"

FILES_${PN}-dbg += "${libdir}/openvpn/plugins/.debug"
FILES_${PN} += "${systemd_unitdir}/system/openvpn@.service \
                ${sysconfdir}/tmpfiles.d \
               "
FILES_${PN}-sample += "${systemd_unitdir}/system/openvpn@loopback-server.service \
                       ${systemd_unitdir}/system/openvpn@loopback-client.service \
                       ${sysconfdir}/openvpn/sample/"
