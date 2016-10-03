FILESEXTRAPATHS_append := ":${THISDIR}/files"

SRC_URI_append = " file://ModemManager.conf.systemd"

do_install_append() {
    install -d ${D}${sysconfdir}/systemd/system/ModemManager.service.d
    install -c -m 0644 ${WORKDIR}/ModemManager.conf.systemd ${D}${sysconfdir}/systemd/system/ModemManager.service.d/ModemManager.conf
}
