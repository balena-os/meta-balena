FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI += " \
	file://0001-networkmanager-trigger-dispatcher-on-per-device-conn.patch \
	file://dispatcher \
	file://ifrecovery \
"

do_install:append() {
	install -d \
    ${D}${sysconfdir}/NetworkManager/dispatcher.d/up.d \
		${D}${sysconfdir}/NetworkManager/dispatcher.d/down.d \
		${D}${sysconfdir}/NetworkManager/dispatcher.d/connectivity-change.d \
		${D}${sysconfdir}/NetworkManager/dispatcher.d/device-connectivity-change.d
	install -m 0755 ${WORKDIR}/dispatcher ${D}${sysconfdir}/NetworkManager/dispatcher.d/01dispatcher
	install -m 0755 ${WORKDIR}/ifrecovery ${D}${sysconfdir}/NetworkManager/dispatcher.d/device-connectivity-change.d/ifrecovery
}
