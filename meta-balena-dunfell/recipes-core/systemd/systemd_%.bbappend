PACKAGECONFIG_remove = "nss-resolve"

do_install_append() {
    # avoid file conflict with timeinit package
    rm ${D}${systemd_unitdir}/system/time-set.target
}

FILES_udev += "\
	${rootlibexecdir}/udev/rules.d/touchscreen.rules \
	${rootlibexecdir}/udev/rules.d/10-zram.rules \
	${rootlibexecdir}/udev/rules.d/60-resin-update-state.rules \
"
