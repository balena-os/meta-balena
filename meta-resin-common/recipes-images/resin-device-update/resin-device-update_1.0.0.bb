DESCRIPTION = "resin device update"
SECTION = "console/utils"
RDEPENDS_${PN} = "cronie rce-run-supervisor"
LICENSE = "Apache-2.0" 
PR = "r1.2"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=435b266b3899aa8a959f17d41c56def8" 
SRC_URI = "file://LICENSE \
	   file://resin-device-update \
	  "

FILES_${PN} = "${bindir}/* ${sysconfdir}/* /var/spool/cron/root"

do_compile() {
}

do_install() {
	install -d ${D}${sysconfdir}/init.d
    	install -d ${D}${sysconfdir}/rc5.d
	install -d ${D}${bindir}
	install -m 0775 ${WORKDIR}/resin-device-update ${D}${bindir}/resin-device-update

	install -d ${D}/var/spool/cron/
	echo "*/5 * * * * /usr/bin/flock -n /tmp/rdu.lcokfile ${bindir}/resin-device-update" > ${D}/var/spool/cron/root
}
