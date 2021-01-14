do_install_append() {
    echo 'connect ""' >> ${D}${sysconfdir}/ppp/options
}
