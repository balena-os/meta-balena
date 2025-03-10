require rust-source.inc
require libstd-rs.inc

LIC_FILES_CHKSUM = "file://../../COPYRIGHT;md5=c2cccf560306876da3913d79062a54b9"

# libstd moved from src/libstd to library/std in 1.47+
S = "${RUSTSRC}/library/std"

BBCLASSEXTEND = "nativesdk"
