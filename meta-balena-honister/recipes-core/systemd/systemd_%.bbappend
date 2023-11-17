PACKAGECONFIG:remove = "nss-resolve"

FILES:udev += "\
	${rootlibexecdir}/udev/rules.d/touchscreen.rules \
	${rootlibexecdir}/udev/rules.d/10-zram.rules \
	${rootlibexecdir}/udev/rules.d/65-resin-update-state.rules \
"
