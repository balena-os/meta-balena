DESCRIPTION = "Docker build for ARM v6"
SECTION = "console/utils"
LICENSE = "Apache-2.0" 
PR = "r0"
# Fill this up with relevent things for docker to run.
DEPENDS = "ca-certificates" 
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=435b266b3899aa8a959f17d41c56def8" 
SRC_URI = "https://s3.amazonaws.com/resin-share/build_requirements/docker-1.0.0.tar.xz;name=docker \
	   file://LICENSE \
	  "
SRC_URI[docker.md5sum] = "82210097a11a876a653ddc8fb87e9e0a"
SRC_URI[docker.sha256sum] = "d7c072f73261ec2ea40f0054263ad415e2a34010651ae9e2f955ba01aace644b"

FILES_${PN} = "${bindir}/*"

do_compile() {
}

do_install() {
	install -d  ${D}${bindir}
	install  -m 0755 ${S}/docker ${D}${bindir}
}

pkg_postinst_${PN} () {
#!/bin/sh -e
# Commands to carry out
}

