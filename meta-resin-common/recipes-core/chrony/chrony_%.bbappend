FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
    file://chrony.conf \
	file://chronyd.conf.systemd \
    "

do_install_append() {
	install -m 0644 ${WORKDIR}/chrony.conf ${D}/${sysconfdir}/chrony.conf

	# Install systemd drop-in for chronyd.service
	install -d 	${D}${sysconfdir}/systemd/system/chronyd.service.d
	install -m 0644 ${WORKDIR}/chronyd.conf.systemd ${D}${sysconfdir}/systemd/system/chronyd.service.d/chronyd.conf
}
