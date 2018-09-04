inherit systemd cargo-dyn binary-compress

DEPENDS += "dbus openssl"

FILES_COMPRESS = "/usr/bin/os-config"

SRC_URI += " \
	file://os-config.json \
	file://os-config.service \
	file://os-config-devicekey.service \
	file://0001-Adjust-CONFIG_JSON_FLASHER_PATH-based-on-OS-changes.patch \
	"

SYSTEMD_SERVICE_${PN} = " \
	os-config.service \
	os-config-devicekey.service \
	"

do_install_append() {
	install -d ${D}${sysconfdir}
	install -m 0644 ${WORKDIR}/os-config.json ${D}${sysconfdir}

	install -d ${D}${systemd_unitdir}/system
	install -c -m 0644 ${WORKDIR}/os-config.service ${D}${systemd_unitdir}/system
	install -c -m 0644 ${WORKDIR}/os-config-devicekey.service ${D}${systemd_unitdir}/system

}
