FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"

SRC_URI_append = " \
	file://0001-core-Don-t-redirect-stdio-to-null-when-running-in-co.patch \
	file://0002-remove_systemd-getty-generator.patch \
	"

PACKAGECONFIG_remove = "nss-resolve"

do_install_append() {
    # avoid file conflict with timeinit package
    rm ${D}${systemd_unitdir}/system/time-set.target
}

FILES_udev += "\
	${rootlibexecdir}/udev/rules.d/touchscreen.rules \
	${rootlibexecdir}/udev/rules.d/10-zram.rules \
	${rootlibexecdir}/udev/rules.d/65-resin-update-state.rules \
"
