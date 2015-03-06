DESCRIPTION = "Board custom INIT file"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r0"

SRC_URI = "file://resin-init-board"

inherit allarch

FILES_${PN} = "${sysconfdir}/*"
RDEPENDS_${PN} = "bash"

do_install() {
	install -d ${D}${sysconfdir}/init.d
	install -m 0755 ${WORKDIR}/resin-init-board  ${D}${sysconfdir}/init.d/
}
