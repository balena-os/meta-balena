DESCRIPTION = "Helper functions for resin test / monitor packages"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = "file://resin-helpers"
S = "${WORKDIR}"

inherit allarch

INSTALL_DIR = "/var/lib/resin"

RDEPENDS_${PN} = "bash"

FILES_${PN} = "${INSTALL_DIR}"

do_install() {
    install -d ${D}${INSTALL_DIR}
    install -m 0755 ${WORKDIR}/resin-helpers ${D}${INSTALL_DIR}
}
