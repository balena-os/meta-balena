FILESEXTRAPATHS_append := ":${THISDIR}/files"
SYSTEMD_AUTO_ENABLE = "enable"

SRC_URI_append = " \
	file://0001-Revert-iface-modem-the-Command-method-is-only-allowe.patch \
	file://0001-helpers-new-parser-for-AT-IFC.patch \
	file://0002-broadband-modem-query-supported-flow-control-modes-b.patch \
	file://0003-wavecom-ignore-custom-flow-control-handling.patch \
	file://0004-telit-ignore-custom-flow-control-handling.patch \
	file://0005-port-serial-new-internal-method-to-run-tcsetattr.patch \
	file://0006-port-serial-new-method-to-explicitly-set-flow-contro.patch \
	file://0007-port-serial-remove-all-default-flow-control-settings.patch \
	file://0008-broadband-bearer-once-connected-set-flow-control-set.patch \
	"
