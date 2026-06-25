SUMMARY = "Kernel-override lifecycle hooks for hostapp extension images"
DESCRIPTION = "Installs /hooks/{create,start,deactivate} into a kernel-override \
extension rootfs."
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit allarch

RDEPENDS:${PN} = " \
    os-helpers-bootenv \
    os-helpers-extensions \
    os-helpers-logging \
    "

SRC_URI = " \
    file://create \
    file://start \
    file://deactivate \
    "

S = "${WORKDIR}"

do_install() {
    install -d ${D}/hooks
    install -m 0755 ${WORKDIR}/create     ${D}/hooks/create
    install -m 0755 ${WORKDIR}/start      ${D}/hooks/start
    install -m 0755 ${WORKDIR}/deactivate ${D}/hooks/deactivate
}

FILES:${PN} = "/hooks /hooks/*"
