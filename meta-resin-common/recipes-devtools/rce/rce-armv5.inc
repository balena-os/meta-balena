DESCRIPTION = "rce build for ARMv5 machines"

include rce.inc

SRC_URI_append = " ${AMAZON_RESIN_SHARE}/rce-armel-${PV}.tar.xz;name=rce"
S = "${WORKDIR}/rce-armel-${PV}"

# ARMv5 binaries
COMPATIBLE_MACHINE = "(-)"
COMPATIBLE_MACHINE_armv5 = "(.*)"
