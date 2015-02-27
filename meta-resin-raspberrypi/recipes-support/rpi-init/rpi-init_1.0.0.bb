DESCRIPTION = "RPI custom INIT file"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r1.27"

SRC_URI = " \
	file://rpi-init \
	file://supervisor.conf \
	file://connman.conf \
	file://interfaces \
	"

FILES_${PN} = "${sysconfdir}/*"
RDEPENDS_${PN} = " \
	bash \
	coreutils \
	util-linux \
	btrfs-tools \
	resin-device-register \
	resin-device-progress \
	tar \
	kmod"

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
