HOMEPAGE = "http://upx.sourceforge.net"
SUMMARY = "Ultimate executable compressor."

SRC_URI = "https://github.com/upx/upx/releases/download/v${PV}/upx-${PV}-src.tar.xz"

SRC_URI[md5sum] = "fa95336d9ddcaac3b494a1b6ae9d3557"
SRC_URI[sha256sum] = "3b0f55468d285c760fcf5ea865a070b27696393002712054c69ff40d8f7f5592"

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

do_install_append() {
    install -d ${D}${bindir}
    install -m 755 ${B}/src/upx.out ${D}${bindir}/upx
    install -d ${D}${mandir}/man1
    install -m 755 ${B}/doc/upx.1 ${D}${mandir}/man1
}

BBCLASSEXTEND = "native"
