DESCRIPTION = "resin device register"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r1.5"

SRC_URI = "file://resin-device-register"
S = "${WORKDIR}"

FILES_${PN} = "${bindir}/*"
RDEPENDS_${PN} = "bash curl jq"

do_install() {
    install -d ${D}${bindir}
    install -m 0775 ${WORKDIR}/resin-device-register ${D}${bindir}/resin-device-register
}

pkg_postinst_${PN} () {
#!/bin/sh -e
# Commands to carry out
# Remove networking
}
