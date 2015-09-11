# we define ${S} to supress build warning complaining about S not being defined
S = "${WORKDIR}"

do_install_append() {
	# Staging Resin build
        if ${@bb.utils.contains('DISTRO_FEATURES','resin-staging','true','false',d)}; then
		echo "Staging environment"
	else
		rm -rf ${D}${systemd_unitdir}/system/serial-getty@.service
		touch ${D}${systemd_unitdir}/system/serial-getty@.service
		rm -rf ${D}${sysconfdir}/systemd/system/getty.target.wants/serial-getty*
	fi

}
