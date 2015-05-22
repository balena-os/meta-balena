SUMMARY = "Resin connman config"
DESCRIPTION = "This is the ConnMan configuration to set up Resin"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://main.conf"

PR = "r0"

FILES_${PN} = "${sysconfdir}/*"

do_install() {
    install -d ${D}${sysconfdir}/connman
    install -m 0755 ${WORKDIR}/main.conf ${D}${sysconfdir}/connman/main.conf
}
