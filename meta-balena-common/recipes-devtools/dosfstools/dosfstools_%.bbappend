FILESEXTRAPATHS:append := ":${THISDIR}/${PN}"

PACKAGES =+ "${PN}-fsck"
FILES:${PN}-fsck = "${sbindir}/*fsck* ${base_sbindir}/*fsck*"
RDEPENDS:${PN}:class-target = "${PN}-fsck"
