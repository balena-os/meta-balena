DESCRIPTION = "rce build for ARMv6 machines"

include rce.inc

SRC_URI_append = " ${AMAZON_RESIN_SHARE}/rce-arm-${PV}.tar.xz;name=rce"
S = "${WORKDIR}/rce-arm-${PV}"

# ARMv6 binaries (ARMv7 compatible)
COMPATIBLE_MACHINE = "(-)"
COMPATIBLE_MACHINE_armv6 = "(.*)"
COMPATIBLE_MACHINE_armv7a = "(.*)"
