SUMMARY = "Data files for usbmodeswitch"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=94d55d512a9ba36caa9b7df079bae19f"

inherit allarch

SRC_URI = "http://www.draisberghof.de/usb_modeswitch/${BP}.tar.bz2"
SRC_URI[md5sum] = "21af977bfc4e7a705d318e88d7a63494"
SRC_URI[sha256sum] = "584d362bc0060c02016edaac7b05ebd6558d5dcbdf14f1ae6d0ec9630265a982"

do_install() {
	oe_runmake install DESTDIR=${D}
}

RDEPENDS_${PN} = "usb-modeswitch (>= 2.2.5)"
FILES_${PN} += "${base_libdir}/udev/rules.d/ \
                ${datadir}/usb_modeswitch"
