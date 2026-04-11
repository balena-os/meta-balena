DESCRIPTION = "Helper tool to tag imported docker images"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit native

SRC_URI = "file://docker-tag-native.sh"

S = "${WORKDIR}"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/docker-tag-native.sh ${D}${bindir}/docker-tag-native
}
