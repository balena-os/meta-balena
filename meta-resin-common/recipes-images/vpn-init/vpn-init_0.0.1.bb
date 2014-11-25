DESCRIPTION = "Resin VPN"
SECTION = "console/utils"
LICENSE = "Apache-2.0" 
PR = "r0.3"
RDEPENDS_${PN} = "openvpn"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=ddcd1a84ad22582096e187ad31540c03" 
SRC_URI = "file://LICENSE \
           file://ca.crt \
           file://client.conf \
           file://vpn-init \
	  "

FILES_${PN} = "${sysconfdir}/* ${bindir}/*"

do_compile() {
}

do_install() {
	install -d ${D}${sysconfdir}/openvpn
	install -m 0755 ${WORKDIR}/client.conf ${D}${sysconfdir}/openvpn/client.conf
	install -m 0755 ${WORKDIR}/ca.crt ${D}${sysconfdir}/openvpn/ca.crt
    
	install -d ${D}${sysconfdir}/init.d
    	install -d ${D}${sysconfdir}/rc5.d
        install -m 0755 ${WORKDIR}/vpn-init  ${D}${sysconfdir}/init.d/vpn-init
        ln -sf ../init.d/vpn-init  ${D}${sysconfdir}/rc5.d/S99vpn-init
        ln -sf ../init.d/openvpn ${D}${sysconfdir}/rc0.d/K21openvpn #Add this only to kill openvpn when exiting.
}

pkg_postinst_${PN} () {
}

