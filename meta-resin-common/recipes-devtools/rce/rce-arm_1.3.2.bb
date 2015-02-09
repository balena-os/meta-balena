DESCRIPTION = "rce build for ARM v6"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=435b266b3899aa8a959f17d41c56def8"

PR = "r2"

SRC_URI = " \
	https://s3.amazonaws.com/resin-share/build_requirements/rce-arm-1.3.2.tar.xz;name=rce \
	file://LICENSE \
	file://cgroupfs-mount \
	"

SRC_URI[rce.md5sum] = "cbd5826254c88d86d4144f2290abc7b1"
SRC_URI[rce.sha256sum] = "163930ea5bad27a543234e8a7d0c97d16558bf40604f1b8ffb57633b2f7f0fb8"
SRC_URI[cgroupfs-mount.md5sum] = "1f7abb7d2c3b1218aaf3d2747b2fd507"
SRC_URI[cgroupfs-mount.sha256sum] = "817f7171fe5d01bfc3b27d9d823a7c0cf3e43dc1191f11dd1be3c7a2abc5804d"

FILES_${PN} = "${bindir}/* ${sysconfdir}/*"
# Fill this up with relevent things for rce to run.
DEPENDS = "ca-certificates"

do_install() {
	install -d  ${D}${bindir}
	nstall  -m 0755 ${S}/rce ${D}${bindir}

	install -d ${D}${sysconfdir}/init.d
	install -d ${D}${sysconfdir}/rcS.d
	install -m 0755 ${WORKDIR}/cgroupfs-mount  ${D}${sysconfdir}/init.d/
	ln -sf ../init.d/cgroupfs-mount  ${D}${sysconfdir}/rcS.d/S90cgroupfs-mount
}

pkg_postinst_${PN} () {
#!/bin/sh -e
# Commands to carry out
}
