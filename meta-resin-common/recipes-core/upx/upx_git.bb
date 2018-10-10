include upx.inc

UPX_BRANCH = "devel"
SRCREV = "f88b85e12660e9fdb453bbb2380107b741ce4179"
SRC_URI = " \
    git://github.com/upx/upx.git;branch=${UPX_BRANCH} \
    file://0001-Include-lzma-sdk.patch"
S = "${WORKDIR}/git"

DEFAULT_PREFERENCE = "-1"
