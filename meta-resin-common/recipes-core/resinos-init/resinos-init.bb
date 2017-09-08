DESCRIPTION = "Resin OS init"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = "file://resinos-init"

S = "${WORKDIR}"

inherit allarch update-alternatives

ALTERNATIVE_${PN} = "init"
ALTERNATIVE_TARGET[init] = "${base_sbindir}/resinos-init"
ALTERNATIVE_LINK_NAME[init] = "${base_sbindir}/init"
ALTERNATIVE_PRIORITY[init] ?= "600"

do_install() {
    mkdir -p ${D}${base_sbindir}
    install -m 0775 ${WORKDIR}/resinos-init ${D}${base_sbindir}
}

FILES_${PN} = "${base_sbindir}"
