FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI_append = " \
    file://defconfig \
    file://balenaos.cfg \
    "

RDEPENDS_${PN}_append = " openssl"
