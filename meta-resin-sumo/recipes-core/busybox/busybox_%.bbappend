FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI_append = " \
	file://0001-Install-link-in-usr-bin-to-match-other-providers.patch \
    "
