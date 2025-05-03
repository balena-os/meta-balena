require rust.inc
inherit cross
require rust-cross.inc
require rust-source.inc

DEPENDS += "virtual/${TARGET_PREFIX}gcc virtual/${TARGET_PREFIX}compilerlibs virtual/libc"
PROVIDES = "virtual/${TARGET_PREFIX}rust"
PN = "rust-cross-${TUNE_PKGARCH}-${TCLIBC}"

# License file checksum needed for do_populate_lic when including a
# Rust app in an image.
LIC_FILES_CHKSUM="file://LICENSE-APACHE;md5=22a53954e4e0ec258dfce4391e905dac"
