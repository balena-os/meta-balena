DESCRIPTION = "rce run supervisor"
SECTION = "console/utils"
LICENSE = "Apache-2.0" 
PR = "r1.2"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=435b266b3899aa8a959f17d41c56def8" 
SRC_URI = "file://LICENSE \
	   file://rce-run-supervisor \
	  "

FILES_${PN} = "${bindir}/*"

do_compile() {
}

do_install() {
	install -d ${D}${bindir}
	install -m 0775 ${WORKDIR}/rce-run-supervisor ${D}${bindir}/rce-run-supervisor
}

pkg_postinst_${PN} () {
#!/bin/sh -e
# Commands to carry out
# Remove networking
}

