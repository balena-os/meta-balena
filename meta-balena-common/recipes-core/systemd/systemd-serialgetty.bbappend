FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " file://development-features.conf"

do_install_append() {
  install -d ${D}${sysconfdir}/systemd/system/serial-getty@.service.d
  install -m 0644 ${WORKDIR}/development-features.conf ${D}${sysconfdir}/systemd/system/serial-getty@.service.d/development-features.conf
}
