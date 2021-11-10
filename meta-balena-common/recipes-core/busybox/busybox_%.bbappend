FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI:append = " \
    file://defconfig \
    file://balenaos.cfg \
    "

RDEPENDS:${PN}:append = " openssl"

ALTERNATIVE_PRIORITY[hwclock] = "100"
