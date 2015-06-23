DESCRIPTION = "rce build for 386"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PROVIDES = "rce"
RPROVIDES_${PN} = "rce"

SRC_URI = " \
    https://s3.amazonaws.com/resin-share/build_requirements/rce-386-${PV}.tar.xz;name=rce \
    file://cgroupfs-mount \
    "

S = "${WORKDIR}/rce-386-${PV}"

SRC_URI[cgroupfs-mount.md5sum] = "1f7abb7d2c3b1218aaf3d2747b2fd507"
SRC_URI[cgroupfs-mount.sha256sum] = "817f7171fe5d01bfc3b27d9d823a7c0cf3e43dc1191f11dd1be3c7a2abc5804d"

# 386 binaries 
COMPATIBLE_MACHINE = "(-)"
COMPATIBLE_MACHINE_edison = "(.*)"

FILES_${PN} = "${bindir}/* /.rce* ${sysconfdir}/* ${localstatedir}/lib/rce*"
# Fill this up with relevent things for rce to run.
RDEPENDS_${PN} = "ca-certificates"

inherit update-rc.d

INITSCRIPT_NAME = "cgroupfs-mount"
INITSCRIPT_PARAMS = "defaults 90"

do_install() {
    install -d ${D}${bindir}
    install -d ${D}/.rce
    mkdir -p ${D}${localstatedir}/lib/rce
    install  -m 0755 ${S}/rce ${D}${bindir}

}

pkg_postinst_${PN} () {
#!/bin/sh -e
# Commands to carry out
}
