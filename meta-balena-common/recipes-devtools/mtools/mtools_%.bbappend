
do_install:append:class-target () {
    install -d ${D}/etc/
    ln -sfr ${D}/run/mtools.conf ${D}/etc/mtools.conf
}
