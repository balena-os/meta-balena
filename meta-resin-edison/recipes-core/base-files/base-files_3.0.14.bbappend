FILESEXTRAPATHS_prepend := "${THISDIR}/base-files:"

SRC_URI += "file://fstab"

FILES_${PN} += "/mnt/data-disk"

do_install_append() {
	# enable mount of the /mnt/data-disk
	mkdir -p ${D}/mnt/data-disk
}
