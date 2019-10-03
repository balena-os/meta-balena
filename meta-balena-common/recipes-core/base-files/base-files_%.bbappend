FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

do_install_append () {
	# Systemd provides mtab so if activated, don't let base-files provide it too
	# We avoid errors at do_rootfs in this way when using opkg
	if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
		rm -f ${D}${sysconfdir}/mtab
	fi

	# Supervisor depends on the existance of /lib/modules even if we don't
	# deploy any kernel modules (ex.: resinOS in container)
	install -d -m 755 ${D}/lib/modules
}
