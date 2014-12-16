DESCRIPTION = "resin device progress"
SECTION = "console/utils"
LICENSE = "Apache-2.0" 
PR = "r1.0"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=435b266b3899aa8a959f17d41c56def8" 
SRC_URI = "file://LICENSE \
	   file://resin-device-progress \
	  "

FILES_${PN} = "${bindir}/*"

do_compile() {
}

do_install() {
	install -d ${D}${bindir}
	install -m 0775 ${WORKDIR}/resin-device-progress ${D}${bindir}/resin-device-progress
}

pkg_postinst_${PN} () {
#!/bin/sh -e
# Commands to carry out
# Remove networking
}

