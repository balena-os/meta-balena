do_install_append () {

	install -d ${D}/${sysconfdir}
	install -m 0400 ${WORKDIR}/fw_env.config ${D}/${sysconfdir}/fw_env.config 

}
