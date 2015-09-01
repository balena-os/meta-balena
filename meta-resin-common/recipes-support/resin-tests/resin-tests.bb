DESCRIPTION = "Resin common functions for resin package tests"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://resin-tests \
    "
S = "${WORKDIR}"

inherit allarch

RESIN_TESTS_DIR = "/var/lib/resin/${PN}"

RDEPENDS_${PN} = "bash"

FILES_${PN} = "${RESIN_TESTS_DIR}"

do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_build[noexec] = "1"

do_install() {
    install -d ${D}${RESIN_TESTS_DIR}
    install -m 0755 ${WORKDIR}/resin-tests ${D}${RESIN_TESTS_DIR}
}
