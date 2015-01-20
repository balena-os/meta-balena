DESCRIPTION = "RPI custom INIT file"
SECTION = "console/utils"
RDEPENDS_${PN} = "resin-device-register resin-device-progress"
LICENSE = "Apache-2.0" 
PR = "r1.25"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=435b266b3899aa8a959f17d41c56def8" 
SRC_URI = "file://LICENSE \
	   file://rpi-init \
	   file://supervisor.conf \
	   file://connman.conf \
	   file://interfaces \
	  "

FILES_${PN} = "${sysconfdir}/*"

do_compile() {
}

do_install() {
	install -d ${D}${sysconfdir}/init.d
    	install -d ${D}${sysconfdir}/rc5.d
	install -d ${D}${sysconfdir}/network
	install -m 0755 ${WORKDIR}/rpi-init  ${D}${sysconfdir}/init.d/
	ln -sf ../init.d/rpi-init  ${D}${sysconfdir}/rc5.d/S06rpi-init

	install -m 0755 ${WORKDIR}/supervisor.conf ${D}${sysconfdir}/
	install -d ${D}${sysconfdir}/connman
	install -m 0755 ${WORKDIR}/connman.conf ${D}${sysconfdir}/connman/main.conf
	install -m 0755 ${WORKDIR}/interfaces ${D}${sysconfdir}/network/

}

pkg_postinst_${PN} () {
#!/bin/sh -e
# Commands to carry out
# Remove networking
}

