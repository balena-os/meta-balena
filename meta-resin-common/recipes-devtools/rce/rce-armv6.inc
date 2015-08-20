DESCRIPTION = "rce build for ARM v6"

include rce.inc

SRC_URI_append = " https://s3.amazonaws.com/resin-share/build_requirements/rce-arm-${PV}.tar.xz;name=rce"
S = "${WORKDIR}/rce-arm-${PV}"

# ARMv6 binaries (ARMv7 compatible)
COMPATIBLE_MACHINE = "(-)"
COMPATIBLE_MACHINE_armv6 = "(.*)"
COMPATIBLE_MACHINE_armv7a = "(.*)"
