
do_install_append_class-target () {
    install -d ${D}/etc/
    ln -sfr ${D}/run/mtools.conf ${D}/etc/mtools.conf
}
