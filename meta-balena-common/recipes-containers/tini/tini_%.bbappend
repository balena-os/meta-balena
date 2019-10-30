# Needed for older yocto layers. Faced a build error in sumo
SECURITY_CFLAGS_pn-${PN} += "${SECURITY_NOPIE_CFLAGS}"
