# No support static PIE
# aufs-utils builds auibusy statically
SECURITY_CFLAGS_pn-${PN} = "${SECURITY_NOPIE_CFLAGS}"
