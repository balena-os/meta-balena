FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI_append = " \
    file://defconfig \
    "

ALTERNATIVE_${PN} += "partprobe"
ALTERNATIVE_LINK_NAME[partprobe] = "${sbindir}/partprobe"
