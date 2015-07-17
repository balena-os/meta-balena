FILESEXTRAPATHS_append_edison := ":${THISDIR}/files"

SRC_URI_append_edison = "file://busybox-log.cfg"

# No syslog services
SYSTEMD_PACKAGES_edison = ""

# Remove alternative syslog files
ALTERNATIVE_${PN}-syslog_remove_edison = "syslog-conf"

do_install_append_edison () {
    # No support for syslog and klogd on edison
    rm -rf ${D}${systemd_unitdir}
    rmdir ${D}${base_libdir}
}
