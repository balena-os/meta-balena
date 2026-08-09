SUMMARY = "Kernel-override lifecycle hooks for hostapp extension images"
DESCRIPTION = "Installs /hooks/{create,start,deactivate} into a kernel-override \
extension rootfs."
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit allarch

# Deliberately no RDEPENDS on os-helpers.

SRC_URI = " \
    file://create \
    file://start \
    file://deactivate \
    "

do_install() {
    install -d ${D}/hooks
    install -m 0755 ${UNPACKDIR}/create     ${D}/hooks/create
    install -m 0755 ${UNPACKDIR}/start      ${D}/hooks/start
    install -m 0755 ${UNPACKDIR}/deactivate ${D}/hooks/deactivate
}

FILES:${PN} = "/hooks /hooks/*"
