FILESEXTRAPATHS:append := ":${THISDIR}/files"

SRC_URI:append = " \
        file://bootchart.conf \
        "

do_install:append() {
        install -m 0644 ${WORKDIR}/bootchart.conf ${D}${sysconfdir}/systemd/bootchart.conf
}
