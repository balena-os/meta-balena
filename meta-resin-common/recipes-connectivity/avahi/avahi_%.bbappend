do_install_append() {
    # Move example services as we don't want to advertise example services
    install -d ${D}/usr/share/doc/${PN}
    mv ${D}/etc/avahi/services/ssh.service ${D}/usr/share/doc/${PN}/
    mv ${D}/etc/avahi/services/sftp-ssh.service ${D}/usr/share/doc/${PN}/
}
