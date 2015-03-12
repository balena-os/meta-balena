FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI = "file://first-install.service \
		file://first-install.target \
		file://first-install.sh \
		file://supervisor.conf \
		file://connman.conf \
		file://interfaces "

FILES_${PN} += "${sysconfdir}/*"

RDEPENDS_${PN} += " \
        bash \
        resin-device-register \
        resin-device-progress \
        resin-net-config"

do_install_append () {

	install -m 0755 ${WORKDIR}/supervisor.conf ${D}${sysconfdir}/
	install -d ${D}${sysconfdir}/connman
	install -m 0755 ${WORKDIR}/connman.conf ${D}${sysconfdir}/connman/main.conf
	install -d ${D}${sysconfdir}/network
	install -m 0755 ${WORKDIR}/interfaces ${D}${sysconfdir}/network/

}
