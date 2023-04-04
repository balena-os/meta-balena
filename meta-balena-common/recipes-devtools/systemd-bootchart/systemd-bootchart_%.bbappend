FILESEXTRAPATHS:append := ":${THISDIR}/files"

SRC_URI:append = "file://bootchart.conf"

# systemd-bootchart is executed by mobynit before systemd, disable the service
SYSTEMD_AUTO_ENABLE:${PN} = "disable"

do_install:append() {
        install -m 0644 ${WORKDIR}/bootchart.conf ${D}${sysconfdir}/systemd/bootchart.conf
}
