FILESEXTRAPATHS_append := ":${THISDIR}/files"

SRC_URI_append = " \
    file://NetworkManager.conf \
    "

do_install_append() {
        install -c -m 0644 ${WORKDIR}/NetworkManager.conf ${D}${sysconfdir}/NetworkManager/
}
