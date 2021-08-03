FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"

SRC_URI_append = " \
	file://0001-core-Don-t-redirect-stdio-to-null-when-running-in-co.patch \
	file://0002-remove_systemd-getty-generator.patch \
	"

PACKAGECONFIG_remove = "nss-resolve"
