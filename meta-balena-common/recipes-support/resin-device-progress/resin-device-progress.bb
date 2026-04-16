DESCRIPTION = "resin device progress"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r2"

SRC_URI = "file://resin-device-progress"

S_UNPACK = "${@d.getVar('UNPACKDIR') or d.getVar('WORKDIR')}"
S = "${S_UNPACK}"

inherit allarch

RDEPENDS:${PN} = " \
    bash \
    curl \
    jq \
    balena-config-vars \
    coreutils \
    "

do_install() {
    install -d ${D}${bindir}
    install -m 0775 ${S_UNPACK}/resin-device-progress ${D}${bindir}/resin-device-progress
}
