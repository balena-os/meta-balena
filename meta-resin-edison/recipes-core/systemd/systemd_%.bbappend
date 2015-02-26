do_install_append() {

	if ${@bb.utils.contains('DISTRO_FEATURES','resin-staging','true','false',d)}; then
		echo "Not removing usb0.network"
	else
		rm ${D}${sysconfdir}/systemd/network/usb0.network
	fi
}
