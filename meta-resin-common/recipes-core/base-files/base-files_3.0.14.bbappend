FILESEXTRAPATHS_prepend := "${THISDIR}/base-files:"

SRC_URI += "file://fstab"

do_install_append() {
    install -m 0644 ${WORKDIR}/fstab ${D}${sysconfdir}/fstab
}
