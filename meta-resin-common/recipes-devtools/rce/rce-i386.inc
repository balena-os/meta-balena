DESCRIPTION = "rce build for 386"

include rce.inc

SRC_URI_append = "https://s3.amazonaws.com/resin-share/build_requirements/rce-386-${PV}.tar.xz;name=rce"
S = "${WORKDIR}/rce-386-${PV}"

# 386 binaries 
COMPATIBLE_MACHINE = "(-)"
COMPATIBLE_MACHINE_x86 = "(.*)"
