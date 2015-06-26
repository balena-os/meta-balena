do_install_append() {
	rm -rf ${D}${sysconfdir}/systemd/system/default.target.wants/media-sdcard.mount
}
