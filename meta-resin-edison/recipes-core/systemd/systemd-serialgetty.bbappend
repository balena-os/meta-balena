do_install_append() {

	# Staging Resin build
        if ${@bb.utils.contains('DISTRO_FEATURES','resin-staging','true','false',d)}; then
		echo "Staging environment"
	else
		rm ${D}${sysconfdir}/systemd/system/getty.target.wants/serial-getty*
	fi

}
