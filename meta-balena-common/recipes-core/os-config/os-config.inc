inherit systemd cargo-dyn pkgconfig

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

S_UNPACK = "${@d.getVar('UNPACKDIR') or d.getVar('WORKDIR')}"

do_compile[network] = "1"
do_install:append() {
	install -d ${D}${sysconfdir}
	install -m 0644 ${S_UNPACK}/os-config.json ${D}${sysconfdir}

	install -d ${D}${systemd_unitdir}/system
	install -c -m 0644 ${S_UNPACK}/os-config.service ${D}${systemd_unitdir}/system
	install -c -m 0644 ${S_UNPACK}/os-config.timer ${D}${systemd_unitdir}/system
	install -c -m 0644 ${S_UNPACK}/os-config-devicekey.service ${D}${systemd_unitdir}/system

}
