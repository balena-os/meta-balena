SUMMARY = "DTB overlays for Beaglebone"
HOMEPAGE = "https://github.com/beagleboard/bb.org-overlays"
SECTION = "bootloader"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://debian/copyright;md5=9682d76c70523c172282bb78caa39cdd"

DEPENDS = "dtc-native"

SRCREV = "182736724ae41f87d4fee0f76b9072135ae328a1"

SRC_URI = " \
    git://github.com/beagleboard/bb.org-overlays.git \
    file://0001-Install-to-DESTDIR.patch \
    "

S = "${WORKDIR}/git"

inherit autotools-brokensep

PACKAGES = "${PN}"
FILES_${PN} += "/lib/firmware"

do_install_prepend () {
    mkdir -p ${D}/lib/firmware
}

PACKAGE_ARCH = "${MACHINE_ARCH}"

COMPATIBLE_MACHINE = "beaglebone"
