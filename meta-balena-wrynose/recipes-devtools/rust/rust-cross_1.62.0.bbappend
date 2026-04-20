# Specify the PROVIDES necessary to fix the build in Wrynose for packages like healthdog, os-config...
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

