DESCRIPTION = "Pack efivar data for hashing to extend PCRs"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
SRC_URI = "git://github.com/balena-os/tcgtool.git;branch=master;protocol=https"
SRCREV = "19dfadb6cff3a09eac8f7e542049cc451db5a05d"

S = "${WORKDIR}/git"

do_compile() {
    oe_runmake ${PN}
}

do_install() {
    install -d ${D}${bindir}
    install -m 755 ${B}/${PN} ${D}${bindir}/${PN}
}

BB_STRICT_CHECKSUM = "0"

BBCLASSEXTEND = "native"
