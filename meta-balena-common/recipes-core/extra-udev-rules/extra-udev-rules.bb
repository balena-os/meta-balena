SUMMARY = "Additional udev rules in the OS"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit allarch

SRC_URI = " \
	file://00-teensy.rules \
	file://79-wlan-power.rules \
	file://99-misc.rules \
	"

do_install:append() {
	# Rules to prevent ModemManager attempting to use Teensy boards as a modem
	install -D -m 0644 ${WORKDIR}/00-teensy.rules ${D}/usr/lib/udev/rules.d/00-teensy.rules

	# Install miscellaneous rules file
	install -D -m 0644 ${WORKDIR}/99-misc.rules ${D}/usr/lib/udev/rules.d/99-misc.rules

	# Install wlan rules file
	install -D -m 0644 ${WORKDIR}/79-wlan-power.rules ${D}/usr/lib/udev/rules.d/79-wlan-power.rules
}
