do_install_append() {
    rm ${D}${datadir}/ModemManager/modem-setup.available.d/0000:0000
}
S = "${WORKDIR}/git"
