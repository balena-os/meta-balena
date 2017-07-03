DESCRIPTION = "Resin custom Docker entry file"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r1"

SRC_URI = " \
    file://entry.sh \
    file://Dockerfile.template \
    "
S = "${WORKDIR}"


RDEPENDS_${PN} = " \
    bash \
    "

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/entry.sh ${D}${bindir}
    install -m 0755 ${WORKDIR}/Dockerfile.template ${DEPLOY_DIR_IMAGE}
}
