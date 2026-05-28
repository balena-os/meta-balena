# Bridge the PROVIDES so Balena's os-config, healthdog, etc., stay happy.
# We explicitly claim the names they are looking for.
PROVIDES = " \
    virtual/${TARGET_PREFIX}rust \
    virtual/aarch64-poky-linux-rust \
    virtual/aarch64-poky-linux-gnu-rust \
"

# Use the GENERIC virtual providers.
# 'virtual/cross-cc' is the internal alias for the C cross-compiler.
# 'virtual/compilerlibs' and 'virtual/libc' are the bare names we verified.
DEPENDS = " \
    virtual/cross-cc \
    virtual/compilerlibs \
    virtual/libc \
    coreutils-native \
"

