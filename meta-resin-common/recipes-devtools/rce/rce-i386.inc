DESCRIPTION = "rce build for 386 machines"

include rce.inc

SRC_URI_append = " ${AMAZON_RESIN_SHARE}/rce-386-${PV}.tar.xz;name=rce"
S = "${WORKDIR}/rce-386-${PV}"

# 386 binaries 
COMPATIBLE_MACHINE = "(-)"
COMPATIBLE_MACHINE_x86 = "(.*)"
