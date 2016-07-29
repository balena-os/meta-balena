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
    # Delete all default themes
    rm -rf ${D}${datadir}/plymouth/themes/*
    rm ${D}${datadir}/plymouth/bizcom.png

    # Delete initrd related operations
    rm ${D}${libdir}/plymouth/plymouth/*initrd

    # Delete set-default-theme as we do not allow this operation
    rm ${D}${sbindir}/plymouth-set-default-theme
    rmdir ${D}${sbindir}

    # Delete the administrator configuration file
    rm ${D}${sysconfdir}/plymouth/plymouthd.conf
    rmdir ${D}${sysconfdir}/plymouth

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

PACKAGES_remove = "${PN}-set-default-theme"
FILES_${PN}-set-default-theme = ""
RDEPENDS_${PN}-set-default-theme = ""

addtask deploy before do_package after do_install
