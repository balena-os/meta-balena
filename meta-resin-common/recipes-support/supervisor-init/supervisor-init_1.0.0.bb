DESCRIPTION = "Resin Supervisor custom INIT file"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r1.32"

SRC_URI = " \
	   file://supervisor-init \
	   file://inittab \
	   file://tty-replacement \
	   file://resin.conf \
	   file://supervisor-init.service \
	  "

FILES_${PN} = "/resin-data /mnt/data-disk ${sysconfdir}/* ${base_bindir}/*"
RDEPENDS_${PN} = "bash rce rce-run-supervisor resin-device-progress wireless-tools resin-supervisor socat"

do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_build[noexec] = "1"

# MIXPANEL TOKEN
MIXPANEL_TOKEN_PRODUCTION = "99eec53325d4f45dd0633abd719e3ff1"
MIXPANEL_TOKEN_STAGING = "cb974f32bab01ecc1171937026774b18"

inherit update-rc.d systemd

INITSCRIPT_NAME = "supervisor-init"
INITSCRIPT_PARAMS = "defaults 99"

SYSTEMD_SERVICE_${PN} = "supervisor-init.service"

do_install() {

	install -d ${D}/resin-data
	install -d ${D}/mnt/data-disk
	install -d ${D}${sysconfdir}/default
	install -d ${D}${sysconfdir}

	install -m 0755 ${WORKDIR}/resin.conf ${D}${sysconfdir}/


	if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
		install -d ${D}${base_bindir}
		install -m 0755 ${WORKDIR}/supervisor-init ${D}${base_bindir}
		install -d ${D}${systemd_unitdir}/system
		install -d ${D}${sysconfdir}/systemd/system/basic.target.wants
		install -c -m 0644 ${WORKDIR}/supervisor-init.service ${D}${systemd_unitdir}/system
		sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
			-e 's,@SBINDIR@,${sbindir},g' \
			-e 's,@BINDIR@,${bindir},g' \
			${D}${systemd_unitdir}/system/*.service

		# enable the service
		ln -sf ${systemd_unitdir}/system/supervisor-init.service \
			${D}${sysconfdir}/systemd/system/basic.target.wants/supervisor-init.service
	else
		install -d ${D}${sysconfdir}/init.d/
		install -m 0755 ${WORKDIR}/supervisor-init  ${D}${sysconfdir}/init.d/supervisor-init
	fi

	# Staging Resin build
	if ${@bb.utils.contains('DISTRO_FEATURES','resin-staging','true','false',d)}; then
		# Staging Resin build
		# Use staging Resin URL
		sed -i -e 's:api.resin.io:api.staging.resin.io:g' ${D}${sysconfdir}/resin.conf
		sed -i -e 's:registry.resin.io:registry.staging.resin.io:g' ${D}${sysconfdir}/resin.conf
		sed -i -e 's:^MIXPANEL_TOKEN=.*:MIXPANEL_TOKEN=${MIXPANEL_TOKEN_STAGING}:g' ${D}${sysconfdir}/resin.conf

		if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
			sed -i -e 's:> /dev/null 2>&1::g' ${D}${base_bindir}/supervisor-init
		else
			sed -i -e 's:> /dev/null 2>&1::g' ${D}${sysconfdir}/init.d/supervisor-init
		fi
	else
		# Production Resin build
		sed -i -e 's:^MIXPANEL_TOKEN=.*:MIXPANEL_TOKEN=${MIXPANEL_TOKEN_PRODUCTION}:g' ${D}${sysconfdir}/resin.conf
		install -m 0755 ${WORKDIR}/inittab ${D}${sysconfdir}/
		install -d ${D}${base_bindir}
		install -m 0755 ${WORKDIR}/tty-replacement ${D}${base_bindir}
	fi

}
do_install[vardeps] += "DISTRO_FEATURES"
