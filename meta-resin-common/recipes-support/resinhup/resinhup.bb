DESCRIPTION = "RESIN Host os UPdater"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = "file://run-resinhup.sh"
S = "${WORKDIR}"

inherit allarch

FILES_${PN} = "${sbindir}"

RDEPENDS_${PN} = " \
    bash \
    jq \
    systemd \
    docker \
    coreutils \
    resin-device-progress \
    "

do_install() {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/run-resinhup.sh ${D}${sbindir}
}
