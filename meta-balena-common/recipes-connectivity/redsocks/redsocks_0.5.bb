FILESEXTRAPATHS:prepend := "${THISDIR}/balena-files:"

DESCRIPTION = "redsocks - transparent socks redirector"
SECTION = "net/misc"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM="file://README;beginline=74;endline=78;md5=edd3a93090d9025f47a1fdec44ace593"

inherit deploy

SRCREV = "27b17889a43e32b0c1162514d00967e6967d41bb"

SRC_URI = " \
	git://github.com/darkk/redsocks.git;branch=master;protocol=https \
	file://0001-using-libevent-2_1_x.patch \
	file://0002-Add-dnsu2t-module-to-convert-DNS-UDP-to-DNS-TCP.patch \
	file://0003-Add-OS-dependent-default-configuration-values.patch \
	file://0004-dnsu2t.c-Fix-dns-relay-when-there-is-no-TFO-cookie-c.patch \
	file://README.ignore \
	file://redsocks.conf.ignore \
"

DEPENDS = "libevent"

S = "${WORKDIR}/git"

do_install () {
    install -d ${D}${bindir}
    install -m 0775 ${S}/redsocks ${D}${bindir}/redsocks
}

do_deploy() {
    mkdir -p "${DEPLOYDIR}/system-proxy/"
    install -m 0600 "${WORKDIR}/redsocks.conf.ignore" "${DEPLOYDIR}/system-proxy/"
    install -m 0600 "${WORKDIR}/README.ignore" "${DEPLOYDIR}/system-proxy/"
}

addtask deploy before do_package after do_install
