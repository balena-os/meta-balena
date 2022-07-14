SUMMARY = "interface to seccomp filtering mechanism"
DESCRIPTION = "The libseccomp library provides and easy to use, platform independent,interface to the Linux Kernel's syscall filtering mechanism: seccomp."
SECTION = "security"
LICENSE = "LGPL-2.1"
LIC_FILES_CHKSUM = "file://LICENSE;beginline=0;endline=1;md5=8eac08d22113880357ceb8e7c37f989f"

DEPENDS += "gperf-native"

SRCREV = "4bf70431a339a2886ab8c82e9a45378f30c6e6c7"

SRC_URI = "git://github.com/seccomp/libseccomp.git;branch=release-2.5 \
           "

COMPATIBLE_HOST:riscv32 = "null"

S = "${WORKDIR}/git"

inherit autotools-brokensep pkgconfig

PACKAGECONFIG ??= ""
PACKAGECONFIG[python] = "--enable-python, --disable-python, python3"

DISABLE_STATIC = ""

FILES:${PN} = "${bindir} ${libdir}/${BPN}.so*"
FILES:${PN}-dbg += "${libdir}/${PN}/tests/.debug/* ${libdir}/${PN}/tools/.debug"
