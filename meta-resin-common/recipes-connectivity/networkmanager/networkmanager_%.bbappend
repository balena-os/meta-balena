DEPENDS += "nss"

FILESEXTRAPATHS_append := ":${THISDIR}/files"

SRC_URI_append = " \
    file://networkmanager.conf \
    file://NetworkManager.conf \
    "

RDEPENDS_${PN}_append = " resin-net-config resolvconf"
FILES_${PN}_append = "${sysconfdir}/*"
EXTRA_OECONF += "--with-resolvconf=/sbin/resolvconf"
PACKAGECONFIG += "systemd modemmanager ppp"

do_install_append() {
    install -m 0644 ${WORKDIR}/NetworkManager.conf ${D}${sysconfdir}/NetworkManager/

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${sysconfdir}/systemd/system/networkmanager.service.d
        install -m 0644 ${WORKDIR}/networkmanager.conf ${D}${sysconfdir}/systemd/system/networkmanager.service.d/
    fi

    ln -s /var/run/resolvconf/interface/NetworkManager ${D}/etc/resolv.dnsmasq

    # removes an error:
    # ERROR: QA Issue: networkmanager: Files/directories were installed but not shipped in any package:
    rm ${D}/usr/share/bash-completion/completions/nmcli
    rm -d ${D}/usr/share/bash-completion/completions/
    rm -d ${D}/usr/share/bash-completion/
}
