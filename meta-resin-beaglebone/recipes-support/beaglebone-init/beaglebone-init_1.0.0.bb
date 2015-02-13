DESCRIPTION = "Resin Beaglebone custom INIT file"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r1.9"

SRC_URI = " \
	file://beaglebone-init \
	file://init-bbb-flasher.sh \
	file://supervisor.conf \
	file://connman.conf \
	"

FILES_${PN} = "${sysconfdir}/* ${bindir}/*"
RDEPENDS_${PN} = " \
	bash \
	util-linux \
	coreutils \
	resin-device-register \
	resin-device-progress \
	parted \
	btrfs-tools \
	rsync \
	e2fsprogs \
	rce \
	jq \
	"

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
