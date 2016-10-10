FILESEXTRAPATHS_append := ":${THISDIR}/files"

SRC_URI_append = " file://avahi-daemon.conf"

FILES_avahi-daemon += "${sysconfdir}/systemd/system/avahi-daemon.service.d/avahi-daemon.conf"

RDEPENDS_avahi-daemon += "resin-hostname"

do_install_append() {
    # Move example services as we don't want to advertise example services
    install -d ${D}/usr/share/doc/${PN}
    mv ${D}/etc/avahi/services/ssh.service ${D}/usr/share/doc/${PN}/
    mv ${D}/etc/avahi/services/sftp-ssh.service ${D}/usr/share/doc/${PN}/

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${sysconfdir}/systemd/system/avahi-daemon.service.d
        install -c -m 0644 ${WORKDIR}/avahi-daemon.conf ${D}${sysconfdir}/systemd/system/avahi-daemon.service.d
    fi
}
