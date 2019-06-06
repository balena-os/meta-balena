inherit update-alternatives

ALTERNATIVE_${PN} += "partprobe"
ALTERNATIVE_PRIORITY = "100"
ALTERNATIVE_LINK_NAME[partprobe] = "${sbindir}/partprobe"
