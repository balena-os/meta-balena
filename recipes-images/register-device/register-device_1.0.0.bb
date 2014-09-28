DESCRIPTION = "Early stage device register"
SECTION = "console/utils"
LICENSE = "Apache-2.0" 
PR = "r0"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=435b266b3899aa8a959f17d41c56def8" 
SRC_URI = "file://LICENSE \
	   file://resin-register-device \
	  "

FILES_${PN} = "${bindir}/*"

do_compile() {
}

do_install() {
	install -d ${D}{bindir}
	install ${WORKDIR}/resin-register-device ${D}{bindir}
}

pkg_postinst_${PN} () {
#!/bin/sh -e
# Commands to carry out
}

