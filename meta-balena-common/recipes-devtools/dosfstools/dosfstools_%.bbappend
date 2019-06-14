FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"
SRC_URI_append = " file://0001-src-check.c-Fix-up-mtools-created-bad-dir-entries.patch"

PACKAGES =+ "${PN}-fsck"
FILES_${PN}-fsck = "${sbindir}/*fsck* ${base_sbindir}/*fsck*"
RDEPENDS_${PN}_class-target = "${PN}-fsck"
