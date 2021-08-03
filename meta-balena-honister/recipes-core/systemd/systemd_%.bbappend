FILESEXTRAPATHS:append := ":${THISDIR}/${PN}"

SRC_URI:append = " \
	file://0001-core-Don-t-redirect-stdio-to-null-when-running-in-co.patch \
	file://0002-remove_systemd-getty-generator.patch \
	"

PACKAGECONFIG:remove = "nss-resolve"

do_install:append() {
    # avoid file conflict with timeinit package
    rm ${D}${systemd_unitdir}/system/time-set.target
}

FILES:udev += "\
	${rootlibexecdir}/udev/rules.d/touchscreen.rules \
	${rootlibexecdir}/udev/rules.d/10-zram.rules \
	${rootlibexecdir}/udev/rules.d/65-resin-update-state.rules \
"
