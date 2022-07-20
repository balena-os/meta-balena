FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI:append = " \
	file://0001-Install-link-in-usr-bin-to-match-other-providers.patch \
    "

ALTERNATIVE:${PN} += "partprobe"
ALTERNATIVE_LINK_NAME[partprobe] = "${sbindir}/partprobe"
