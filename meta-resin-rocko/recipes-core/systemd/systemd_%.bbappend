FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"

SRC_URI_append = " \
	file://0001-core-Don-t-redirect-stdio-to-null-when-running-in-co.patch
	file://0002-remove_systemd-getty-generator.patch \
	file://0003-Don-t-run-specific-services-in-container.patch \
	"

# add pool.ntp.org as default ntp server
PACKAGECONFIG[ntp] = "--with-ntp-servers='0.resinio.pool.ntp.org 1.resinio.pool.ntp.org 2.resinio.pool.ntp.org 3.resinio.pool.ntp.org',,,"
