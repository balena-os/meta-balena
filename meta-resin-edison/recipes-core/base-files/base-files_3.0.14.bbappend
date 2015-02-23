FILESEXTRAPATHS_prepend := "${THISDIR}/base-files:"

SRC_URI += "file://fstab"

do_install_append() {
	rm ${D}${sysconfdir}/systemd/system/default.target.wants/media-sdcard.mount
}
