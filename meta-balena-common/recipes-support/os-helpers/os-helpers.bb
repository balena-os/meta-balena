DESCRIPTION = "Helpers for OS scripts"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

DEPENDS = "time-native"
RDEPENDS_${PN}-fs = "e2fsprogs-tune2fs mtools btrfs-tools"

SRC_URI = " \
    file://os-helpers-fs \
    file://os-helpers-logging \
    file://os-helpers-time \
"
S = "${WORKDIR}"

inherit allarch

PACKAGES = "${PN}-fs ${PN}-logging ${PN}-time"

do_install() {
    install -d ${D}${libexecdir}
    install -m 0775 \
        ${WORKDIR}/os-helpers-fs \
        ${WORKDIR}/os-helpers-logging \
        ${WORKDIR}/os-helpers-time \
        ${D}${libexecdir}
}

FILES_${PN}-fs = "${libexecdir}/os-helpers-fs"
FILES_${PN}-logging = "${libexecdir}/os-helpers-logging"
FILES_${PN}-time = "${libexecdir}/os-helpers-time"
