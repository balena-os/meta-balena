do_install:append() {
    echo 'connect ""' >> ${D}${sysconfdir}/ppp/options
}
