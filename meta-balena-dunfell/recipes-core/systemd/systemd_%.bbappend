FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"

SRC_URI_append = " \
	file://0001-core-Don-t-redirect-stdio-to-null-when-running-in-co.patch \
	"

do_install_append() {
    # avoid file conflict with timeinit package
    rm ${D}${systemd_unitdir}/system/time-set.target
}

