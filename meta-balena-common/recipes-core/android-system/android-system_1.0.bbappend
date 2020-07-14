FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

SRC_URI_append = " file://android-system.conf"

do_install_append() {
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${sysconfdir}/systemd/system/android-system.service.d
        install -c -m 0644 ${WORKDIR}/android-system.conf ${D}${sysconfdir}/systemd/system/android-system.service.d
    fi
}
