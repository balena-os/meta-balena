HOMEPAGE = "http://upx.sourceforge.net"
SUMMARY = "Ultimate executable compressor."
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://LICENSE;md5=353753597aa110e0ded3508408c6374a"

inherit perlnative

DEPENDS += "zlib ucl"

S = "${WORKDIR}/${BPN}-${PV}-src"

# CHECK_WHITESPACE breaks cross builds: https://github.com/upx/upx/issues/64
EXTRA_OEMAKE = "CHECK_WHITESPACE=/bin/true"

do_compile() {
    oe_runmake all
}

do_install:append() {
    install -d ${D}${bindir}
    install -m 755 ${B}/src/upx.out ${D}${bindir}/upx
    if [ -z "${UPX_NO_DOC}" ]; then
        install -d ${D}${mandir}/man1
        install -m 755 ${B}/doc/upx.1 ${D}${mandir}/man1
    fi
}

BBCLASSEXTEND = "native"
