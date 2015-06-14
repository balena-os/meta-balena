DESCRIPTION = "Resin Configuration file"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r0"

SRC_URI = "file://resin.conf"
S = "${WORKDIR}"

FILES_${PN} = "${sysconfdir}"

do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_build[noexec] = "1"

# MIXPANEL Staging/Production TOKEN
MIXPANEL_TOKEN_PRODUCTION = "99eec53325d4f45dd0633abd719e3ff1"
MIXPANEL_TOKEN_STAGING = "cb974f32bab01ecc1171937026774b18"

do_install() {
    install -d ${D}${sysconfdir}
    install -m 0755 ${WORKDIR}/resin.conf ${D}${sysconfdir}/

    if ${@bb.utils.contains('DISTRO_FEATURES','resin-staging','true','false',d)}; then
        # Staging Resin build
        sed -i -e 's:api.resin.io:api.resinstaging.io:g' ${D}${sysconfdir}/resin.conf
        sed -i -e 's:registry.resin.io:registry.staging.resin.io:g' ${D}${sysconfdir}/resin.conf
        sed -i -e 's:^MIXPANEL_TOKEN=.*:MIXPANEL_TOKEN=${MIXPANEL_TOKEN_STAGING}:g' ${D}${sysconfdir}/resin.conf
    else
        # Production Resin build
        sed -i -e 's:^MIXPANEL_TOKEN=.*:MIXPANEL_TOKEN=${MIXPANEL_TOKEN_PRODUCTION}:g' ${D}${sysconfdir}/resin.conf
    fi
}
do_install[vardeps] += "DISTRO_FEATURES"
