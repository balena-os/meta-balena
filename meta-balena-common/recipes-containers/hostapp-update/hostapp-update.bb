DESCRIPTION = "Resin hostapp updater"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
	file://hostapp-update \
	"

S_UNPACK = "${@d.getVar('UNPACKDIR') or d.getVar('WORKDIR')}"
S = "${S_UNPACK}"

inherit allarch

BBCLASSEXTEND = "native"

FILES:${PN} = "${bindir}"

RDEPENDS:${PN} += " \
    balena \
    "

RDEPENDS:${PN}:class-target += "os-helpers-reboot"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S_UNPACK}/hostapp-update ${D}${bindir}
}
