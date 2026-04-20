PROVIDES += " \
    virtual/${TARGET_PREFIX}gnu-rust \
"
# Use the GENERIC virtual providers when building with Wrynose.
# 'virtual/cross-cc' is the internal alias for the C cross-compiler
DEPENDS = " \
    virtual/cross-cc \
    virtual/compilerlibs \
    virtual/libc \
    coreutils-native \
"
