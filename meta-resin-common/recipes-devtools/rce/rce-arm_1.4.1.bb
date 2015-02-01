DESCRIPTION = "rce build for ARM v6"
SECTION = "console/utils"
LICENSE = "Apache-2.0" 
PR = "r3"
# Fill this up with relevent things for rce to run.
RDEPENDS_${PN} = "ca-certificates"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=435b266b3899aa8a959f17d41c56def8" 
SRC_URI = "https://s3.amazonaws.com/resin-share/build_requirements/rce-arm-1.4.1.tar.xz;name=rce \
	   file://LICENSE \
	   file://cgroupfs-mount \
	  "

SRC_URI[rce.md5sum] = "8951d0e170a70db3d22033aa3bdb98f1"
SRC_URI[rce.sha256sum] = "c9e93a359ec003f83585940f71e38ae9b5a0479486ca85d84d707e23ccbd9b61"
SRC_URI[cgroupfs-mount.md5sum] = "1f7abb7d2c3b1218aaf3d2747b2fd507"
SRC_URI[cgroupfs-mount.sha256sum] = "817f7171fe5d01bfc3b27d9d823a7c0cf3e43dc1191f11dd1be3c7a2abc5804d"

FILES_${PN} = "${bindir}/* /.rce* ${sysconfdir}/* ${localstatedir}/lib/rce*"

do_compile() {
}

do_install() {
	install -d ${D}${bindir}
	install -d ${D}/.rce
	install -d ${D}${localstatedir}
	install -d ${D}${localstatedir}/lib
	install -d ${D}${localstatedir}/lib/rce
	install  -m 0755 ${S}/rce ${D}${bindir}
    
	install -d ${D}${sysconfdir}/init.d
    	install -d ${D}${sysconfdir}/rcS.d
	install -m 0755 ${WORKDIR}/cgroupfs-mount  ${D}${sysconfdir}/init.d/
	ln -sf ../init.d/cgroupfs-mount  ${D}${sysconfdir}/rcS.d/S90cgroupfs-mount 
}

pkg_postinst_${PN} () {
#!/bin/sh -e
# Commands to carry out
}

