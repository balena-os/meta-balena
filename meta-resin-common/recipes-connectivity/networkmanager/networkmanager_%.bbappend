RCONFLICTS_${PN}_remove = "connman"

FILESEXTRAPATHS_append := ":${THISDIR}/files"

SRC_URI_append = " \
    file://networkmanager.conf \
    file://NetworkManager.conf \
    file://resolv.conf.sh \
    file://gio_gio.h.patch \
    "

# "patch" for the 1.0.4 recipe, not needed with 1.0.12
PACKAGECONFIG[ppp] = "--enable-ppp,--disable-ppp,ppp,ppp"

RDEPENDS_${PN}_append = " resin-net-config"
FILES_${PN}_append = "${sysconfdir}/*"
SYSTEMD_AUTO_ENABLE = "disable"
EXTRA_OECONF += "--with-resolvconf=/usr/sbin/resolv.conf.sh"
PACKAGECONFIG += "systemd modemmanager ppp"

do_install_append() {
    install -m 0644 ${WORKDIR}/NetworkManager.conf ${D}${sysconfdir}/NetworkManager/
    install -m 0755 ${WORKDIR}/resolv.conf.sh ${D}/usr/sbin/

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${sysconfdir}/systemd/system/networkmanager.service.d
        install -m 0644 ${WORKDIR}/networkmanager.conf ${D}${sysconfdir}/systemd/system/networkmanager.service.d/
    fi
}
