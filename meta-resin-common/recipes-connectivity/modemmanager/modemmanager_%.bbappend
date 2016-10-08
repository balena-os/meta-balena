FILESEXTRAPATHS_append := ":${THISDIR}/files"
SYSTEMD_AUTO_ENABLE = "enable"

SRC_URI_append = " file://0001-Revert-iface-modem-the-Command-method-is-only-allowe.patch"

do_install_append() {
    install -d ${D}${sysconfdir}/systemd/system/ModemManager.service.d
    install -c -m 0644 ${WORKDIR}/ModemManager.conf.systemd ${D}${sysconfdir}/systemd/system/ModemManager.service.d/ModemManager.conf
}
