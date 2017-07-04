HOMEPAGE = "http://upx.sourceforge.net"
SUMMARY = "Ultimate executable compressor."

SRC_URI = " \
    http://upx.sourceforge.net/download/${PN}-${PV}-src.tar.bz2 \
    http://downloads.sourceforge.net/sevenzip/lzma465.tar.bz2;name=lzma;subdir=lzma-465 \
    file://fix_indentation_for_gcc6.patch \
    "

SRC_URI[md5sum] = "c6d0b3ea2ecb28cb8031d59a4b087a43"
SRC_URI[sha256sum] = "527ce757429841f51675352b1f9f6fc8ad97b18002080d7bf8672c466d8c6a3c"
SRC_URI[lzma.md5sum] = "29d5ffd03a5a3e51aef6a74e9eafb759"
SRC_URI[lzma.sha256sum] = "c935fd04dd8e0e8c688a3078f3675d699679a90be81c12686837e0880aa0fa1e"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://LICENSE;md5=353753597aa110e0ded3508408c6374a"

inherit native

DEPENDS = "zlib ucl"

S = "${WORKDIR}/${PN}-${PV}-src"

do_compile() {
    oe_runmake UPX_LZMA_VERSION=0x465 UPX_LZMADIR="${WORKDIR}/lzma-465" all
}

do_install_append() {
    install -d ${D}${bindir}
    install -m 755 ${B}/src/upx.out ${D}${bindir}/upx
}
