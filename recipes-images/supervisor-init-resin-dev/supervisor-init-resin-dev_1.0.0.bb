DESCRIPTION = "Resin Supervisor custom INIT file"
SECTION = "console/utils"
LICENSE = "Apache-2.0" 
PR = "r1.14"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=435b266b3899aa8a959f17d41c56def8" 
SRC_URI = "file://LICENSE \
	   file://supervisor-init \
	   file://resin.conf \
	  "

FILES_${PN} = "${sysconfdir}/*"

do_compile() {
}

do_install() {

	install -d ${D}${sysconfdir}/init.d
    	install -d ${D}${sysconfdir}/rc5.d

	install -m 0755 ${WORKDIR}/supervisor-init  ${D}${sysconfdir}/init.d/
	install -m 0755 ${WORKDIR}/resin.conf ${D}${sysconfdir}/

	ln -sf ../init.d/supervisor-init  ${D}${sysconfdir}/rc5.d/S99supervisor-init

}

pkg_postinst_${PN} () {
#!/bin/sh -e
# Commands to carry out
}

