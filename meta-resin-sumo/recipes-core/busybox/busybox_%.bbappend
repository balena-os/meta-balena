FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI_append = " \
	file://0001-Install-link-in-usr-bin-to-match-other-providers.patch \
    "

ALTERNATIVE_${PN} += "partprobe"
ALTERNATIVE_LINK_NAME[partprobe] = "${sbindir}/partprobe"
