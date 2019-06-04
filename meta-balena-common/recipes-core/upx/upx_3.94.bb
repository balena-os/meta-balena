include upx.inc

SRC_URI = "https://github.com/upx/upx/releases/download/v${PV}/upx-${PV}-src.tar.xz"
SRC_URI[md5sum] = "19e898edc41bde3f21e997d237156731"
SRC_URI[sha256sum] = "81ef72cdac7d8ccda66c2c1ab14f4cd54225e9e7b10cd40dd54be348dbf25621"

UPX_NO_DOC = "1"
