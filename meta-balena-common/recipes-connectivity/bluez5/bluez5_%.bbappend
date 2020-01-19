FILESEXTRAPATHS_append := ":${THISDIR}/files"

SRC_URI += " \
    file://10-local-bt-hci-up.rules \
    file://bluetooth.conf.systemd \
    file://run-bluetoothd-with-experimental-flag.patch \
    "

do_install_append() {
    install -D -m 0755 ${WORKDIR}/10-local-bt-hci-up.rules ${D}/lib/udev/rules.d/10-local-bt-hci-up.rules

    install -d ${D}${sysconfdir}/systemd/system/bluetooth.service.d
    install -m 0644 ${WORKDIR}/bluetooth.conf.systemd ${D}${sysconfdir}/systemd/system/bluetooth.service.d/bluetooth.conf

    install -d ${D}/var/lib/bluetooth
}

PACKAGECONFIG_append = " sixaxis"
