FILESEXTRAPATHS_append := ":${THISDIR}/files"

SRC_URI_append = " \
    file://chrony.conf \
    "

do_install_append() {
    install -m 0644 ${WORKDIR}/chrony.conf ${D}/${sysconfdir}/chrony.conf
}
