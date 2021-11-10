ALTERNATIVE:${PN} += "mke2fs"
ALTERNATIVE_LINK_NAME[mke2fs] = "${base_sbindir}/mke2fs"

FILESEXTRAPATHS:prepend := "${THISDIR}/os-files:"
SRC_URI += "file://e2fsck.conf"

do_install:append() {
	install -m 644 ${WORKDIR}/e2fsck.conf ${D}${sysconfdir}
}

CONFFILES:${PN} += "${sysconfdir}/e2fsck.conf"
FILES:e2fsprogs-e2fsck += "${sysconfdir}/e2fsck.conf"
