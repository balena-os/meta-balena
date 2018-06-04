#
# meta-openembedded recipe, edited as little as possible
#

SUMMARY = "NetworkManager"
SECTION = "net/misc"

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://COPYING;md5=cbbffd568227ada506640fe950a4823b \
                    file://libnm-util/COPYING;md5=1c4fa765d6eb3cd2fbd84344a1b816cd \
                    file://docs/api/html/license.html;md5=697fa2cd28065955314b0bcf5ab1ff04 \
"

DEPENDS = "intltool-native libnl dbus dbus-glib dbus-glib-native libgudev util-linux libndp libnewt polkit"

inherit gnomebase gettext systemd bluetooth vala

SRC_URI = " \
    ${GNOME_MIRROR}/NetworkManager/${@gnome_verdir("${PV}")}/NetworkManager-${PV}.tar.xz \
"
SRC_URI[md5sum] = "42d83efdff7f23381c0971981222b491"
SRC_URI[sha256sum] = "169c34f50770e3c96b431f7d2cff654455246f2e6ccd46eccfb4454d4595625b"

S = "${WORKDIR}/NetworkManager-${PV}"

EXTRA_OECONF = " \
    --disable-ifcfg-rh \
    --disable-ifnet \
    --disable-ifcfg-suse \
    --disable-json-validation \
    --disable-more-warnings \
    --with-iptables=${sbindir}/iptables \
    --with-tests \
    --with-nmtui=yes \
"

do_compile_prepend() {
        export GIR_EXTRA_LIBS_PATH="${B}/libnm-util/.libs"
}

PACKAGECONFIG ??= "nss ifupdown netconfig dhclient dnsmasq \
    ${@bb.utils.contains('DISTRO_FEATURES','systemd','systemd','consolekit',d)} \
    ${@bb.utils.contains('DISTRO_FEATURES','bluetooth','${BLUEZ}','',d)} \
    ${@bb.utils.contains('DISTRO_FEATURES','wifi','wifi','',d)} \
"
PACKAGECONFIG[systemd] = " \
    --with-systemdsystemunitdir=${systemd_unitdir}/system --with-session-tracking=systemd --enable-polkit, \
    --without-systemdsystemunitdir, \
    polkit \
"
PACKAGECONFIG[bluez5] = "--enable-bluez5-dun,--disable-bluez5-dun,bluez5"
# consolekit is not picked by shlibs, so add it to RDEPENDS too
PACKAGECONFIG[consolekit] = "--with-session-tracking=consolekit,,consolekit,consolekit"
PACKAGECONFIG[modemmanager] = "--with-modem-manager-1=yes,--with-modem-manager-1=no,modemmanager"
PACKAGECONFIG[ppp] = "--enable-ppp,--disable-ppp,ppp,ppp"
# Use full featured dhcp client instead of internal one
PACKAGECONFIG[dhclient] = "--with-dhclient=${base_sbindir}/dhclient,,,dhcp-client"
PACKAGECONFIG[dnsmasq] = "--with-dnsmasq=${bindir}/dnsmasq"
PACKAGECONFIG[nss] = "--with-crypto=nss,,nss"
PACKAGECONFIG[gnutls] = "--with-crypto=gnutls,,gnutls libgcrypt"
PACKAGECONFIG[wifi] = "--enable-wifi=yes,--enable-wifi=no,wireless-tools,wpa-supplicant wireless-tools"
PACKAGECONFIG[ifupdown] = "--enable-ifupdown,--disable-ifupdown"
PACKAGECONFIG[netconfig] = "--with-netconfig=yes,--with-netconfig=no"
PACKAGECONFIG[qt4-x11-free] = "--enable-qt,--disable-qt,qt4-x11-free"

PACKAGES =+ "libnmutil libnmglib libnmglib-vpn ${PN}-tests \
  ${PN}-nmtui ${PN}-nmtui-doc \
  ${PN}-adsl \
"

FILES_libnmutil += "${libdir}/libnm-util.so.*"
FILES_libnmglib += "${libdir}/libnm-glib.so.*"
FILES_libnmglib-vpn += "${libdir}/libnm-glib-vpn.so.*"

FILES_${PN}-adsl = "${libdir}/NetworkManager/libnm-device-plugin-adsl.so"

FILES_${PN} += " \
    ${libexecdir} \
    ${libdir}/pppd/*/nm-pppd-plugin.so \
    ${libdir}/NetworkManager/*.so \
    ${datadir}/polkit-1 \
    ${datadir}/dbus-1 \
    ${base_libdir}/udev/* \
    ${systemd_unitdir}/system \
"

RRECOMMENDS_${PN} += "iptables \
    ${@bb.utils.contains('PACKAGECONFIG','dnsmasq','dnsmasq','',d)} \
"

FILES_${PN}-dbg += " \
    ${libdir}/NetworkManager/.debug/ \
    ${libdir}/pppd/*/.debug/ \
"

FILES_${PN}-dev += " \
    ${datadir}/NetworkManager/gdb-cmd \
    ${libdir}/pppd/*/*.la \
    ${libdir}/NetworkManager/*.la \
"

FILES_${PN}-tests = " \
    ${bindir}/nm-online \
"

FILES_${PN}-nmtui = " \
    ${bindir}/nmtui \
    ${bindir}/nmtui-edit \
    ${bindir}/nmtui-connect \
    ${bindir}/nmtui-hostname \
"

FILES_${PN}-nmtui-doc = " \
    ${mandir}/man1/nmtui* \
"

SYSTEMD_SERVICE_${PN} = "NetworkManager.service NetworkManager-dispatcher.service"

do_install_append() {
    rm -rf ${D}/run ${D}${localstatedir}/run
}
