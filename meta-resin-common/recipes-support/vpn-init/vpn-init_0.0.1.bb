DESCRIPTION = "Resin VPN"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r0.14"

SRC_URI = " \
	file://ca.crt \
	file://client.conf \
	file://vpn-init \
	file://failsafe-sshkey.pub \
	file://vpn-init.service \
	"
S = "${WORKDIR}"

FILES_${PN} = "${sysconfdir}/* ${base_bindir}/* ${bindir}/* /home/root/.ssh/* ${localstatedir}/lib/dropbear/* /etc/default/dropbear"
RDEPENDS_${PN} = "bash openvpn jq"

inherit update-rc.d systemd
INITSCRIPT_NAME = "vpn-init"
INITSCRIPT_PARAMS = "defaults 99"

SYSTEMD_SERVICE_${PN} = "vpn-init.service"

do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_build[noexec] = "1"

do_install() {
	install -d ${D}${sysconfdir}/openvpn

	install -m 0755 ${WORKDIR}/client.conf ${D}${sysconfdir}/openvpn/client.conf
	install -m 0755 ${WORKDIR}/ca.crt ${D}${sysconfdir}/openvpn/ca.crt

	# Staging Resin build
	if ${@bb.utils.contains('DISTRO_FEATURES','resin-staging','true','false',d)}; then
		# Use staging Resin URL
		sed -i -e 's:vpn.resin.io:vpn.staging.resin.io:g' ${D}${sysconfdir}/openvpn/client.conf
	# Production Resin Build
	else
		# Change dropbear to disable root password logins
		install -d ${D}${sysconfdir}/default
		echo 'DROPBEAR_EXTRA_ARGS="-g"' >> ${D}/etc/default/dropbear
	fi

	mkdir -p ${D}/home/root/.ssh
	mkdir -p ${D}${localstatedir}/lib/dropbear/ # This will enable the authorized_keys to be updated even when the device has read_only root.
	install -m 0400 ${WORKDIR}/failsafe-sshkey.pub ${D}/${localstatedir}/lib/dropbear/authorized_keys
	ln -sf ../../../var/lib/dropbear/authorized_keys ${D}/home/root/.ssh/authorized_keys

	install -d ${D}${sysconfdir}/default
	echo 'DROPBEAR_PORT="22222"' >> ${D}/etc/default/dropbear # Change default dropbear port to 22222


	if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
		install -d ${D}${base_bindir}
		install -m 0755 ${WORKDIR}/vpn-init ${D}${base_bindir}
		install -d ${D}${systemd_unitdir}/system
		install -d ${D}${sysconfdir}/systemd/system/basic.target.wants
		install -c -m 0644 ${WORKDIR}/vpn-init.service ${D}${systemd_unitdir}/system
		sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
			-e 's,@SBINDIR@,${sbindir},g' \
			-e 's,@BINDIR@,${bindir},g' \
			${D}${systemd_unitdir}/system/*.service

		# enable the service
		ln -sf ${systemd_unitdir}/system/vpn-init.service \
			${D}${sysconfdir}/systemd/system/basic.target.wants/vpn-init.service
	else
		install -d ${D}${sysconfdir}/init.d/
		install -m 0755 ${WORKDIR}/vpn-init  ${D}${sysconfdir}/init.d/vpn-init
	fi


}
do_install[vardeps] += "DISTRO_FEATURES"
