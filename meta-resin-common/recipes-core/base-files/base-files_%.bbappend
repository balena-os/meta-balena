do_install_append () {
	# Systemd provides mtab so if activated, don't let base-files provide it too
	# We avoid errors at do_rootfs in this way when using opkg
	if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
		rm -f ${D}${sysconfdir}/mtab
	fi
}
