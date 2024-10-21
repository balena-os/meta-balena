inherit systemd cargo-dyn

DEPENDS += "dbus openssl pkgconfig-native"

SRC_URI += " \
	file://os-config.json \
	file://os-config.service \
	file://os-config.timer \
	file://os-config-devicekey.service \
	file://0001-Adjust-CONFIG_JSON_FLASHER_PATH-based-on-OS-changes.patch \
	file://0002-Add-auth.-header-to-os-v1-config-requests.patch \
	"

SYSTEMD_SERVICE:${PN} = " \
	os-config.service \
	os-config.timer \
	os-config-devicekey.service \
	"

do_compile[network] = "1"
do_install:append() {
	install -d ${D}${sysconfdir}
	install -m 0644 ${WORKDIR}/os-config.json ${D}${sysconfdir}

	install -d ${D}${systemd_unitdir}/system
	install -c -m 0644 ${WORKDIR}/os-config.service ${D}${systemd_unitdir}/system
	install -c -m 0644 ${WORKDIR}/os-config.timer ${D}${systemd_unitdir}/system
	install -c -m 0644 ${WORKDIR}/os-config-devicekey.service ${D}${systemd_unitdir}/system

}
