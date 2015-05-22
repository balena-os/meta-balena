FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI_append = " file://ENV-IS-NOWHERE.patch"
