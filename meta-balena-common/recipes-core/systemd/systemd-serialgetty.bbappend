FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " file://development-features.conf"

do_install:append() {
  install -d ${D}${sysconfdir}/systemd/system/serial-getty@.service.d
  install -m 0644 ${UNPACKDIR}/development-features.conf ${D}${sysconfdir}/systemd/system/serial-getty@.service.d/development-features.conf
}
