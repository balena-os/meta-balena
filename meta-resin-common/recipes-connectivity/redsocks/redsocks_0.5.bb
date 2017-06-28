DESCRIPTION = "redsocks - transparent socks redirector"
SECTION = "net/misc"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM="file://README;beginline=74;endline=78;md5=edd3a93090d9025f47a1fdec44ace593"

SRCREV = "27b17889a43e32b0c1162514d00967e6967d41bb"

SRC_URI = "git://github.com/darkk/redsocks.git"

DEPENDS = "libevent"

S = "${WORKDIR}/git"

do_install () {
    install -d ${D}${bindir}
    install -m 0775 ${S}/redsocks ${D}${bindir}/redsocks
}
