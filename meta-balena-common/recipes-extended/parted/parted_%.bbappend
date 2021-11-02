inherit update-alternatives

ALTERNATIVE:${PN} += "partprobe"
ALTERNATIVE_PRIORITY = "100"
ALTERNATIVE_LINK_NAME[partprobe] = "${sbindir}/partprobe"
