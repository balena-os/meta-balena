# Temporary fix for https://bugzilla.yoctoproject.org/show_bug.cgi?id=7769
do_install_append () {
    install -d ${D}/${sysconfdir}/dbus-1/system.d
    install -m 644 ${S}/wpa_supplicant/dbus/dbus-wpa_supplicant.conf ${D}/${sysconfdir}/dbus-1/system.d
}
