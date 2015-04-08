FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
	file://rce.cfg \
	file://leds.cfg \
	"
