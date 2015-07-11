FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI_append = " file://init-external-media.sh"

do_install_append() {
    install -m 0755 ${WORKDIR}/init-external-media.sh ${D}/init
}
