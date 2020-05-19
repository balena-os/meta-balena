FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI_append = " \
    file://defconfig \
    file://balenaos.cfg \
    "
SRC_URI_remove = " \
    file://syslog.cfg \
    "

RDEPENDS_${PN}_append = " openssl"
