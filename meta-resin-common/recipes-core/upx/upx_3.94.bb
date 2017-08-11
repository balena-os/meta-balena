HOMEPAGE = "http://upx.sourceforge.net"
SUMMARY = "Ultimate executable compressor."

SRC_URI = "https://github.com/upx/upx/releases/download/v${PV}/upx-${PV}-src.tar.xz"

SRC_URI[md5sum] = "19e898edc41bde3f21e997d237156731"
SRC_URI[sha256sum] = "81ef72cdac7d8ccda66c2c1ab14f4cd54225e9e7b10cd40dd54be348dbf25621"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://LICENSE;md5=353753597aa110e0ded3508408c6374a"

DEPENDS = "zlib ucl-native"

S = "${WORKDIR}/${BPN}-${PV}-src"

# CHECK_WHITESPACE breaks cross builds: https://github.com/upx/upx/issues/64
EXTRA_OEMAKE = "CHECK_WHITESPACE=/bin/true"

do_compile() {
    oe_runmake all
}

do_install_append() {
    install -d ${D}${bindir}
    install -m 755 ${B}/src/upx.out ${D}${bindir}/upx
}

BBCLASSEXTEND = "native"
