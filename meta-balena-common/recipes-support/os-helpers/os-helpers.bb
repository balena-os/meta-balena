DESCRIPTION = "Helpers for OS scripts"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

DEPENDS = "time-native"
RDEPENDS_${PN}-fs = "e2fsprogs-tune2fs mtools"

SRC_URI = " \
    file://os-helpers-fs \
    file://os-helpers-logging \
"
S = "${WORKDIR}"

inherit allarch

PACKAGES = "${PN}-fs ${PN}-logging"

do_install() {
    install -d ${D}${libexecdir}
    install -m 0775 \
        ${WORKDIR}/os-helpers-fs \
        ${WORKDIR}/os-helpers-logging \
        ${D}${libexecdir}
}

FILES_${PN}-fs = "${libexecdir}/os-helpers-fs"
FILES_${PN}-logging = "${libexecdir}/os-helpers-logging"
