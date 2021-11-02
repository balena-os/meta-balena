# Thud static PIE seems broken as binary gets into segfault at runtime
SECURITY_CFLAGS:pn-${PN} += "${SECURITY_NOPIE_CFLAGS}"
