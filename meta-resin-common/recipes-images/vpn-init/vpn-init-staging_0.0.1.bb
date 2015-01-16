DESCRIPTION = "Resin VPN"
SECTION = "console/utils"
LICENSE = "Apache-2.0" 
PR = "r0.9"
RDEPENDS_${PN} = "openvpn"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=ddcd1a84ad22582096e187ad31540c03" 
SRC_URI = "file://LICENSE \
           file://ca-staging.crt \
           file://client-staging.conf \
           file://vpn-init \
           file://failsafe-sshkey.pub \
	  "

FILES_${PN} = "${sysconfdir}/* ${bindir}/* /home/root/.ssh/* ${localstatedir}/lib/dropbear/* /etc/default/dropbear"

do_compile() {
}

do_install() {
	install -d ${D}${sysconfdir}/openvpn
	install -m 0755 ${WORKDIR}/client-staging.conf ${D}${sysconfdir}/openvpn/client.conf
	install -m 0755 ${WORKDIR}/ca-staging.crt ${D}${sysconfdir}/openvpn/ca.crt
    
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
}

pkg_postinst_${PN} () {
}
