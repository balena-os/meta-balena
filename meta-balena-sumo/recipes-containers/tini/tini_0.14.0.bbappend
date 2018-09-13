# Sumo static PIE seems broken as binary gets into segfault at runtime
SECURITY_CFLAGS_pn-${PN} += "${SECURITY_NOPIE_CFLAGS}"
