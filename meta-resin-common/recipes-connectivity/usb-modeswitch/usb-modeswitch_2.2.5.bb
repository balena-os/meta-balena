# This package is a requirement for 3G USB modem support.
#
# Use this particular version, not the one shipped with openembedded,
# because Ubuntu uses this version and we wish to use an Ubuntu patch.
#

SUMMARY = "A mode switching tool for controlling 'flip flop' (multiple device) USB gear"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=94d55d512a9ba36caa9b7df079bae19f"

DEPENDS = "libpipeline libusb1 udev"

SRC_URI = " \
	http://www.draisberghof.de/usb_modeswitch/${BP}.tar.bz2 \
	file://dispatcher-c-rewrite.patch \
	"
SRC_URI[md5sum] = "ef86a19f0b3c4f64896d78a2ffb748e9"
SRC_URI[sha256sum] = "8b2340303732aabc8c8e1cdd7d4352f61dcb942839f58ce22ba0ecfa122426d5"

FILES_${PN} = "${bindir} ${sysconfdir} ${nonarch_base_libdir}/udev/usb_modeswitch ${sbindir} ${localstatedir}/lib/usb_modeswitch"
RRECOMMENDS_${PN} = "usb-modeswitch-data"

TARGET_CC_ARCH += "${LDFLAGS}"

do_compile() {
	oe_runmake shared
}

do_install() {
	oe_runmake DESTDIR=${D} install-shared
}
