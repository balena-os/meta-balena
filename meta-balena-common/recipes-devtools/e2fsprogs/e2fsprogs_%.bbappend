ALTERNATIVE_${PN} += "mke2fs"
ALTERNATIVE_LINK_NAME[mke2fs] = "${base_sbindir}/mke2fs"

FILESEXTRAPATHS_prepend := "${THISDIR}/os-files:"
SRC_URI += "file://e2fsck.conf"

do_install_append() {
	install -m 644 ${WORKDIR}/e2fsck.conf ${D}${sysconfdir}
}

CONFFILES_${PN} += "${sysconfdir}/e2fsck.conf"
FILES_e2fsprogs-e2fsck += "${sysconfdir}/e2fsck.conf"
