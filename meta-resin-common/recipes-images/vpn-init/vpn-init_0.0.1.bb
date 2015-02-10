DESCRIPTION = "Resin VPN"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r0.10"

SRC_URI = " \
	file://ca.crt \
	file://client.conf \
	file://vpn-init \
	file://failsafe-sshkey.pub \
	"

FILES_${PN} = "${sysconfdir}/* ${bindir}/* /home/root/.ssh/* ${localstatedir}/lib/dropbear/* /etc/default/dropbear"
RDEPENDS_${PN} = "bash openvpn"

do_install() {
	install -d ${D}${sysconfdir}/openvpn
	install -m 0755 ${WORKDIR}/client.conf ${D}${sysconfdir}/openvpn/client.conf
	install -m 0755 ${WORKDIR}/ca.crt ${D}${sysconfdir}/openvpn/ca.crt
    
	install -d ${D}${sysconfdir}/init.d
	install -d ${D}${sysconfdir}/rc5.d
	install -m 0755 ${WORKDIR}/vpn-init  ${D}${sysconfdir}/init.d/vpn-init
	ln -sf ../init.d/vpn-init  ${D}${sysconfdir}/rc5.d/S99vpn-init
	
	mkdir -p ${D}/home/root/.ssh
	mkdir -p ${D}${localstatedir}/lib/dropbear/ # This will enable the authorized_keys to be updated even when the device has read_only root.
	install -m 0400 ${WORKDIR}/failsafe-sshkey.pub ${D}/${localstatedir}/lib/dropbear/authorized_keys
	ln -sf ../../../var/lib/dropbear/authorized_keys ${D}/home/root/.ssh/authorized_keys

	install -d ${D}${sysconfdir}/default
	echo 'DROPBEAR_PORT="22222"' >> ${D}/etc/default/dropbear # Change default dropbear port to 22222
	echo 'DROPBEAR_EXTRA_ARGS="-g"' >> ${D}/etc/default/dropbear # Change dropbear to disable root password logins
}

pkg_postinst_${PN} () {
}
