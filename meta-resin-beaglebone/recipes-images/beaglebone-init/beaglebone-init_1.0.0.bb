DESCRIPTION = "Resin Beaglebone custom INIT file"
SECTION = "console/utils"
RDEPENDS_${PN} = "resin-device-register resin-device-progress"
LICENSE = "Apache-2.0" 
PR = "r1.6"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=435b266b3899aa8a959f17d41c56def8" 
SRC_URI = "file://LICENSE \
	   file://beaglebone-init \
	   file://init-bbb-flasher.sh \
	   file://supervisor.conf \
	   file://connman.conf \
	  "

FILES_${PN} = "${sysconfdir}/* ${bindir}/*"

do_compile() {
}

do_install() {
	install -d ${D}${sysconfdir}/init.d
    	install -d ${D}${sysconfdir}/rc5.d
	install -m 0755 ${WORKDIR}/beaglebone-init  ${D}${sysconfdir}/init.d/
	ln -sf ../init.d/beaglebone-init  ${D}${sysconfdir}/rc5.d/S06beaglebone-init

	install -m 0755 ${WORKDIR}/supervisor.conf ${D}${sysconfdir}/
	install -d ${D}${sysconfdir}/connman
	install -m 0755 ${WORKDIR}/connman.conf ${D}${sysconfdir}/connman/main.conf
	
	install -d ${D}${bindir}
	install -m 0755 ${WORKDIR}/init-bbb-flasher.sh ${D}${bindir}/init-bbb-flasher.sh

}

pkg_postinst_${PN} () {
#!/bin/sh -e
# Commands to carry out
}

