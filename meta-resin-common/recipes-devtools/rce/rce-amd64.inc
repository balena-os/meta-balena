DESCRIPTION = "rce build for x86 64 bits machines"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PROVIDES = "rce"
RPROVIDES_${PN} = "rce"

SRC_URI = "https://s3.amazonaws.com/resin-share/build_requirements/rce-amd64-${PV}.tar.xz;name=rce"

S = "${WORKDIR}/rce-amd64-${PV}"

# amd64 binaries 
COMPATIBLE_MACHINE = "(-)"
COMPATIBLE_MACHINE_x86-64 = "(.*)"

FILES_${PN} = "${bindir}/* /.rce* ${sysconfdir}/* ${localstatedir}/lib/rce*"
# Fill this up with relevent things for rce to run.
RDEPENDS_${PN} = "ca-certificates"

do_install() {
    install -d ${D}${bindir}
    install -d ${D}/.rce
    mkdir -p ${D}${localstatedir}/lib/rce
    install  -m 0755 ${S}/rce ${D}${bindir}
}
