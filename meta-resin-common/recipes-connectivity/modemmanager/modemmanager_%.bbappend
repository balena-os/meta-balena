FILESEXTRAPATHS_append := ":${THISDIR}/files"
SYSTEMD_AUTO_ENABLE = "enable"

SRC_URI_append = " file://debug.diff"
