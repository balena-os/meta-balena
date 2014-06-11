DESCRIPTION = "Docker build for ARM v6"
SECTION = "console/utils"
LICENSE = "Apache-2.0" 
PR = "r0"
# Fill this up with relevent things for docker to run.
DEPENDS = "ca-certificates" 
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=435b266b3899aa8a959f17d41c56def8" 
SRC_URI = "https://s3.amazonaws.com/resin-share/build_requirements/docker-1.0.0.tar.xz;name=docker \
	   file://LICENSE \
	   file://cgroupfs-mount \
	  "

SRC_URI[docker.md5sum] = "82210097a11a876a653ddc8fb87e9e0a"
SRC_URI[docker.sha256sum] = "d7c072f73261ec2ea40f0054263ad415e2a34010651ae9e2f955ba01aace644b"
SRC_URI[cgroupfs-mount.md5sum] = "1f7abb7d2c3b1218aaf3d2747b2fd507"
SRC_URI[cgroupfs-mount.sha256sum] = "817f7171fe5d01bfc3b27d9d823a7c0cf3e43dc1191f11dd1be3c7a2abc5804d"

FILES_${PN} = "${bindir}/* ${sysconfdir}/*"

do_compile() {
}

do_install() {
	install -d  ${D}${bindir}
	install  -m 0755 ${S}/docker ${D}${bindir}
    
	install -d ${D}${sysconfdir}/init.d
    	install -d ${D}${sysconfdir}/rcS.d
	install -m 0755 ${WORKDIR}/cgroupfs-mount  ${D}${sysconfdir}/init.d/
	ln -sf ../init.d/cgroupfs-mount  ${D}${sysconfdir}/rcS.d/S90cgroupfs-mount 
}

pkg_postinst_${PN} () {
#!/bin/sh -e
# Commands to carry out
}

