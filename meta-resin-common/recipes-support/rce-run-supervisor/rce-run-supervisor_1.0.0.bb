DESCRIPTION = "rce run supervisor"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r1.6"

SRC_URI = "file://rce-run-supervisor"
S = "${WORKDIR}"

FILES_${PN} = "${bindir}/*"
RDEPENDS_${PN} = "bash rce"

do_install() {
	install -d ${D}${bindir}
	install -m 0775 ${WORKDIR}/rce-run-supervisor ${D}${bindir}/rce-run-supervisor
}

pkg_postinst_${PN} () {
#!/bin/sh -e
# Commands to carry out
# Remove networking
}
