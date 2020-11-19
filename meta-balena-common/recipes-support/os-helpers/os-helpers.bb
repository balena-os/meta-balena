DESCRIPTION = "Helpers for OS scripts"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

DEPENDS = "time-native"
RDEPENDS:${PN}-fs = "e2fsprogs-tune2fs mtools btrfs-tools"
RDEPENDS:${PN}-tpm2 = "libtss2-tcti-device tpm2-tools"

SRC_URI = " \
    file://os-helpers-fs \
    file://os-helpers-logging \
    file://os-helpers-time \
    file://os-helpers-tpm2 \
    file://os-helpers-devmode \
"
S = "${WORKDIR}"

inherit allarch

PACKAGES = "${PN}-fs ${PN}-logging ${PN}-time ${PN}-tpm2 ${PN}-devmode"

do_install() {
    install -d ${D}${libexecdir}
    install -m 0775 \
        ${WORKDIR}/os-helpers-fs \
        ${WORKDIR}/os-helpers-logging \
        ${WORKDIR}/os-helpers-time \
        ${WORKDIR}/os-helpers-tpm2 \
        ${WORKDIR}/os-helpers-devmode \
        ${D}${libexecdir}
}

FILES:${PN}-fs = "${libexecdir}/os-helpers-fs"
FILES:${PN}-logging = "${libexecdir}/os-helpers-logging"
FILES:${PN}-time = "${libexecdir}/os-helpers-time"
FILES:${PN}-tpm2 = "${libexecdir}/os-helpers-tpm2"
FILES:${PN}-devmode = "${libexecdir}/os-helpers-devmode"
