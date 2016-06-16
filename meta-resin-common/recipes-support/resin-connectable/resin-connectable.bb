DESCRIPTION = "Tool for managing resin connectable OS"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = "file://resin-connectable"
S = "${WORKDIR}"

inherit allarch

FILES_${PN} = "${sbindir}"

RDEPENDS_${PN} = "bash"

do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_build[noexec] = "1"

do_install() {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/resin-connectable ${D}${sbindir}/
}
