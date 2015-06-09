DESCRIPTION = "resin device update"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r3"

SRC_URI = "file://resin-device-update"
S = "${WORKDIR}"

FILES_${PN} = "${bindir}/*"
RDEPENDS_${PN} = "bash cronie rce rce-run-supervisor util-linux jq resin-conf"

do_install() {
	install -d ${D}${bindir}
	install -m 0775 ${WORKDIR}/resin-device-update ${D}${bindir}/resin-device-update

}

pkg_postinst_${PN}() {
#!/bin/sh -e
mkdir -p $D/var/spool/cron
echo "*/5 * * * * /usr/bin/flock -n /tmp/rdu.lockfile ${bindir}/resin-device-update" >> $D/var/spool/cron/root
}
