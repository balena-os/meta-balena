FILESEXTRAPATHS_append := ":${THISDIR}/files"

SRC_URI += " \
	file://10-local-bt-hci-up.rules \
	file://run-bluetoothd-with-experimental-flag.patch \
	"

do_install_append() {
    install -D -m 0755 ${WORKDIR}/10-local-bt-hci-up.rules ${D}/etc/udev/rules.d/10-local-bt-hci-up.rules
}
