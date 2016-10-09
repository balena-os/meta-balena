FILESEXTRAPATHS_append := ":${THISDIR}/files"
SYSTEMD_AUTO_ENABLE = "enable"

SRC_URI_append = " file://0001-Revert-iface-modem-the-Command-method-is-only-allowe.patch"
