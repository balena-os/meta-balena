SUMMARY = "Additional udev rules in the OS"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit allarch

SRC_URI = " \
	file://49-teensy.rules \
	file://99-misc.rules \
	"

do_install_append() {
	# Rules to prevent ModemManager attempting to use Teensy boards as a modem
	install -D -m 0644 ${WORKDIR}/49-teensy.rules ${D}/lib/udev/rules.d/49-teensy.rules

	# Install miscellaneous rules file
	install -D -m 0644 ${WORKDIR}/99-misc.rules ${D}/lib/udev/rules.d/99-misc.rules
}
