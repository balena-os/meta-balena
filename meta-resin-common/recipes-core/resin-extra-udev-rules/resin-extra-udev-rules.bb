SUMMARY = "Teensy udev rules"
DESCRIPTION = "Rules to prevent ModemManager attempting to use Teensy boards as a modem"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit allarch

FILESEXTRAPATHS_append := ":${THISDIR}/files"

SRC_URI_append = " file://49-teensy.rules"

do_install_append() {
    install -D -m 0644 ${WORKDIR}/49-teensy.rules ${D}/lib/udev/rules.d/
}
