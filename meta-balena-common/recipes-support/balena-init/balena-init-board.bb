DESCRIPTION = "Board custom INIT file"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r1"

SRC_URI = "file://balena-init-board"
S = "${WORKDIR}"

inherit allarch

RDEPENDS:${PN} = "bash"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/balena-init-board ${D}${bindir}
    ln -s balena-init-board ${D}${bindir}/resin-init-board
}
