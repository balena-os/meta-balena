
FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"
SRC_URI_append = " file://initialize-direntry.patch"

do_install_append_class-target () {
    install -d ${D}/etc/
    ln -sfr ${D}/run/mtools.conf ${D}/etc/mtools.conf
}
