FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " file://development-features.conf"

S_UNPACK = "${@d.getVar('UNPACKDIR') or d.getVar('WORKDIR')}"

do_install:append() {
  install -d ${D}${sysconfdir}/systemd/system/serial-getty@.service.d
  install -m 0644 ${S_UNPACK}/development-features.conf ${D}${sysconfdir}/systemd/system/serial-getty@.service.d/development-features.conf
}
