DESCRIPTION = "RPI custom INIT file"
SECTION = "console/utils"
LICENSE = "Apache-2.0" 
PR = "r1.13"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=435b266b3899aa8a959f17d41c56def8" 
SRC_URI = "file://LICENSE \
	   file://rpi-init \
	   file://supervisor-init \
	   file://connman.conf \
	  "

FILES_${PN} = "${sysconfdir}/*"

do_compile() {
}

do_install() {
    
	install -d ${D}${sysconfdir}/init.d
    	install -d ${D}${sysconfdir}/rc5.d
	install -m 0755 ${WORKDIR}/rpi-init  ${D}${sysconfdir}/init.d/
	install -m 0755 ${WORKDIR}/supervisor-init  ${D}${sysconfdir}/init.d/
	ln -sf ../init.d/rpi-init  ${D}${sysconfdir}/rc5.d/S03rpi-init
	ln -sf ../init.d/supervisor-init  ${D}${sysconfdir}/rc5.d/S99supervisor-init

	install -d ${D}${sysconfdir}/connman
	install -m 0755 ${WORKDIR}/connman.conf ${D}${sysconfdir}/connman/main.conf
}

pkg_postinst_${PN} () {
#!/bin/sh -e
# Commands to carry out
}

