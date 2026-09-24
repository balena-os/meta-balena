DESCRIPTION = "Pack efivar data for hashing to extend PCRs"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
SRC_URI = "git://github.com/balena-os/tcgtool.git;branch=master;protocol=https;destsuffix=git"
SRCREV = "19dfadb6cff3a09eac8f7e542049cc451db5a05d"
S = "${@d.getVar('UNPACKDIR') or d.getVar('WORKDIR')}/git"

# Explicitly define and use the binary name to
# avoid native build failures in Wrynose
REAL_PN = "tcgtool"

do_compile() {
    oe_runmake ${REAL_PN}
}

do_install() {
    install -d ${D}${bindir}
    install -m 755 ${B}/${REAL_PN} ${D}${bindir}/${REAL_PN}
}

BB_STRICT_CHECKSUM = "0"

BBCLASSEXTEND = "native"
