DESCRIPTION = "Resin custom INIT file"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r5"

SRC_URI = " \
	file://resin-init \
	file://connman.conf \
	file://interfaces \
	"

inherit update-rc.d allarch

INITSCRIPT_NAME = "resin-init"
INITSCRIPT_PARAMS = "start 06 5 ."

FILES_${PN} = "${sysconfdir}/*"
RDEPENDS_${PN} = " \
    resin-init-board \
    bash \
    coreutils \
    util-linux \
    btrfs-tools \
    resin-device-register \
    resin-device-progress \
    resin-net-config \
    mtools \
    "

do_install() {
	install -d ${D}${sysconfdir}/init.d
	install -m 0755 ${WORKDIR}/resin-init  ${D}${sysconfdir}/init.d/

	install -d ${D}${sysconfdir}/connman
	install -m 0755 ${WORKDIR}/connman.conf ${D}${sysconfdir}/connman/main.conf

	install -d ${D}${sysconfdir}/network
	install -m 0755 ${WORKDIR}/interfaces ${D}${sysconfdir}/network/
}
