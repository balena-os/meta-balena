DESCRIPTION = "Resin Supervisor custom INIT file"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r1.26"

SRC_URI = " \
	   file://supervisor-init \
	   file://inittab \
	   file://tty-replacement \
	   file://resin.conf \
	  "

FILES_${PN} = "${sysconfdir}/* ${base_bindir}/*"
RDEPENDS_${PN} = "bash rce rce-run-supervisor resin-device-progress wireless-tools"

do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_build[noexec] = "1"

# MIXPANEL TOKEN
MIXPANEL_TOKEN_PRODUCTION = "99eec53325d4f45dd0633abd719e3ff1"
MIXPANEL_TOKEN_STAGING = "cb974f32bab01ecc1171937026774b18"

do_install() {
	# Staging Resin build
	if ${@bb.utils.contains('DISTRO_FEATURES','resin-staging','true','false',d)}; then
		# Use staging Resin URL
		sed -i -e 's:api.resin.io:staging.resin.io:g' ${WORKDIR}/resin.conf
		sed -i -e 's:registry.resin.io:registry.staging.resin.io:g' ${WORKDIR}/resin.conf
		sed -i -e 's:^MIXPANEL_TOKEN=.*:MIXPANEL_TOKEN=${MIXPANEL_TOKEN_STAGING}:g' ${WORKDIR}/resin.conf
		sed -i -e 's:> /dev/null 2>&1::g' ${WORKDIR}/supervisor-init
	else
		sed -i -e 's:^MIXPANEL_TOKEN=.*:MIXPANEL_TOKEN=${MIXPANEL_TOKEN_PRODUCTION}:g' ${WORKDIR}/resin.conf
	fi

	install -d ${D}${sysconfdir}/init.d
	install -d ${D}${sysconfdir}/rc5.d
	install -d ${D}${sysconfdir}/default
	install -d ${D}${sysconfdir}
	install -d ${D}${base_bindir}

	install -m 0755 ${WORKDIR}/supervisor-init  ${D}${sysconfdir}/init.d/
	install -m 0755 ${WORKDIR}/resin.conf ${D}${sysconfdir}/

	ln -sf ../init.d/supervisor-init  ${D}${sysconfdir}/rc5.d/S99supervisor-init
	install -m 0755 ${WORKDIR}/inittab ${D}${sysconfdir}/
	install -m 0755 ${WORKDIR}/tty-replacement ${D}${base_bindir}
}
do_install[vardeps] += "DISTRO_FEATURES"

pkg_postinst_${PN} () {
#!/bin/sh -e
# Commands to carry out
}
