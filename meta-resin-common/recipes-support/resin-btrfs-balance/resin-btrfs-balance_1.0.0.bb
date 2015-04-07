DESCRIPTION = "resin btrfs balance"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r1.0"

SRC_URI = "file://resin-btrfs-balance"

FILES_${PN} = "${bindir}/*"
RDEPENDS_${PN} = "bash cronie btrfs-tools util-linux"

do_install() {
	install -d ${D}${bindir}
	install -m 0775 ${WORKDIR}/resin-btrfs-balance ${D}${bindir}/resin-btrfs-balance
}

pkg_postinst_${PN}() {
#!/bin/sh -e

mkdir -p $D/var/spool/cron
#Run resin-btrfs-balance once every day at midnight
echo "0 0 * * * /usr/bin/flock -n /tmp/rbb.lockfile ${bindir}/resin-btrfs-balance" >> $D/var/spool/cron/root
#Run resin-btrfs-balance on reboot
echo "@reboot /usr/bin/flock -n /tmp/rbb.lockfile ${bindir}/resin-btrfs-balance" >> $D/var/spool/cron/root
}
