DESCRIPTION = "rce build for x86 64 bits machines"

include rce.inc

SRC_URI = "https://s3.amazonaws.com/resin-share/build_requirements/rce-amd64-${PV}.tar.xz;name=rce"
S = "${WORKDIR}/rce-amd64-${PV}"

# amd64 binaries 
COMPATIBLE_MACHINE = "(-)"
COMPATIBLE_MACHINE_x86-64 = "(.*)"
