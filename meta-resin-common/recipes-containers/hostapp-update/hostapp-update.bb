DESCRIPTION = "Resin hostapp updater"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
	file://hostapp-update \
	"
S = "${WORKDIR}"

inherit allarch

BBCLASSEXTEND = "native"

FILES_${PN} = "${bindir}"

RDEPENDS_${PN} = " \
    balena \
    "

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/hostapp-update ${D}${bindir}
}
