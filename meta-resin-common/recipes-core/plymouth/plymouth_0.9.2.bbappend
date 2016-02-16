FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

inherit deploy

SRC_URI_append = " \
    file://0001-plymouth-systemd-append.patch \
    file://0002-plymouth-default-theme-is-resin.patch \
    file://resin-logo.png \
    file://resin.script \
    file://resin.plymouth \
    "

do_install_append() {
    install -d ${D}${datadir}/plymouth/themes/resin
    install -m 644 ${WORKDIR}/resin.script ${D}${datadir}/plymouth/themes/resin/
    install -m 644 ${WORKDIR}/resin.plymouth ${D}${datadir}/plymouth/themes/resin/
}

do_deploy() {
  install ${WORKDIR}/resin-logo.png ${DEPLOYDIR}/resin-logo.png
}

PACKAGES_remove = "${PN}-initrd"
FILES_${PN}-initrd = ""
RDEPENDS_${PN}-initrd = ""

addtask deploy before do_package after do_install
