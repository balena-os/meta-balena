require rust.inc
inherit cross
require rust-cross.inc
require rust-source.inc

#DEPENDS += "virtual/${TARGET_PREFIX}gcc virtual/${TARGET_PREFIX}compilerlibs virtual/libc"
#PROVIDES = "virtual/${TARGET_PREFIX}rust"
PN = "rust-cross-${TUNE_PKGARCH}-${TCLIBC}"

# 1. Keep the triplet definitions for Rust's internal logic
TARGET_VENDOR = "-poky"
TARGET_OS = "linux-gnu"

# 2. Bridge the PROVIDES so Balena's os-config, healthdog, etc., stay happy.
# We explicitly claim the names they are looking for.
PROVIDES = " \
    virtual/${TARGET_PREFIX}rust \
    virtual/aarch64-poky-linux-rust \
    virtual/aarch64-poky-linux-gnu-rust \
"

# 3. Use the GENERIC virtual providers.
# 'virtual/cross-cc' is the internal alias for the C cross-compiler.
# 'virtual/compilerlibs' and 'virtual/libc' are the bare names we verified.
DEPENDS = " \
    virtual/cross-cc \
    virtual/compilerlibs \
    virtual/libc \
    coreutils-native \
"
