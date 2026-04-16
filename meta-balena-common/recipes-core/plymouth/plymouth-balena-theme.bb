SUMMARY = "Plymouth Balena theme."
DESCRIPTION = "A simple plymouth theme for BalenaOS devices"

SECTION = "base"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

RDEPENDS:${PN} = "plymouth"

SRC_URI = " \
    file://balena.script \
    file://balena.plymouth \
    file://plymouthd.defaults \
    "

inherit allarch

S_UNPACK = "${@d.getVar('UNPACKDIR') or d.getVar('WORKDIR')}"

do_install () {
    mkdir -p ${D}${datadir}/plymouth/themes/balena
    install -m 644 ${S_UNPACK}/balena.script ${D}${datadir}/plymouth/themes/balena/
    install -m 644 ${S_UNPACK}/balena.plymouth ${D}${datadir}/plymouth/themes/balena/
    install -m 644 ${S_UNPACK}/plymouthd.defaults ${D}${datadir}/plymouth/
}

FILES:${PN} = "${datadir}/plymouth/*"
