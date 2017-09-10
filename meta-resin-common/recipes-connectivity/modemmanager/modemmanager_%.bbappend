FILESEXTRAPATHS_append := ":${THISDIR}/resin-files"
SYSTEMD_AUTO_ENABLE = "enable"

SRC_URI_append = " \
    file://0001-Revert-iface-modem-the-Command-method-is-only-allowe.patch \
    file://0002-ModemManager.service.in-Log-to-systemd-journal.patch \
    file://77-mm-huawei-configuration.rules \
    file://mm-huawei-configuration-switch.sh \
"

do_install_append() {
    install -d ${D}/etc/udev/rules.d/
    install -d ${D}/lib/udev/
    install -m 0644 ${WORKDIR}/77-mm-huawei-configuration.rules ${D}/etc/udev/rules.d/
    install -m 0755 ${WORKDIR}/mm-huawei-configuration-switch.sh ${D}/lib/udev/
}

FILES_${PN} += " \
    /etc/udev/rules.d/77-mm-huawei-configuration.rules \
    /lib/udev/mm-huawei-configuration-switch.sh \
    "
DEPENDS_append = " libxslt-native"
