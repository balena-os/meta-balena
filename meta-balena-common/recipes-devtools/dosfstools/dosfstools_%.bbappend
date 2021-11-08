FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"

PACKAGES =+ "${PN}-fsck"
FILES_${PN}-fsck = "${sbindir}/*fsck* ${base_sbindir}/*fsck*"
RDEPENDS_${PN}_class-target = "${PN}-fsck"
