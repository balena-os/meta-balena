DESCRIPTION = "RPI custom INIT file"
SECTION = "console/utils"
LICENSE = "Apache-2.0" 
PR = "r1.15"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=435b266b3899aa8a959f17d41c56def8" 
SRC_URI = "file://LICENSE \
	   file://rpi-init \
	   file://connman.conf \
	   file://resin-register-device \
	  "

FILES_${PN} = "${sysconfdir}/* ${bindir}/*"

do_compile() {
}

do_install() {
	install -d ${D}${bindir}
	install -m 0775 ${WORKDIR}/resin-register-device ${D}${bindir}/resin-register-device
    
	install -d ${D}${sysconfdir}/init.d
    	install -d ${D}${sysconfdir}/rc5.d
	install -m 0755 ${WORKDIR}/rpi-init  ${D}${sysconfdir}/init.d/
	ln -sf ../init.d/rpi-init  ${D}${sysconfdir}/rc5.d/S06rpi-init

	install -d ${D}${sysconfdir}/connman
	install -m 0755 ${WORKDIR}/connman.conf ${D}${sysconfdir}/connman/main.conf

}

pkg_postinst_${PN} () {
#!/bin/sh -e
# Commands to carry out
# Remove networking
}

