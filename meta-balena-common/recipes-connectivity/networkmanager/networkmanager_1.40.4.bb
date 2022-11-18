SUMMARY = "NetworkManager"
HOMEPAGE = "https://wiki.gnome.org/Projects/NetworkManager"
SECTION = "net/misc"

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
                    file://docs/api/html/license.html;md5=4b6f0196cf1f53deecf4300c0b290f4b \
"

DEPENDS = " \
    intltool-native \
    libxslt-native \
    libnl \
    libgudev \
    util-linux \
    libndp \
    libnewt \
    jansson \
    curl \
"

inherit gnomebase gettext systemd bash-completion vala gobject-introspection gtk-doc

SRC_URI = " \
    ${GNOME_MIRROR}/NetworkManager/${@gnome_verdir("${PV}")}/NetworkManager-${PV}.tar.xz \
    file://0001-Fixed-configure.ac-Fix-pkgconfig-sysroot-locations.patch \
"
SRC_URI:append:libc-musl = " \
    file://musl/0001-Fix-build-with-musl-systemd-specific.patch \
    file://musl/0002-Fix-build-with-musl.patch \
"
SRC_URI[md5sum] = "82088af23cac1be7394bde000f4612f8"
SRC_URI[sha256sum] = "b23214b5481c80f93f7515fcdeac11c09c8c96466872d7ec386d64fb5fd12cbf"

UPSTREAM_CHECK_URI = "${GNOME_MIRROR}/NetworkManager/${@gnome_verdir("${PV}")}/"
# Stable releases are numbered 1.y.z, with y and z being even numbers.
UPSTREAM_CHECK_REGEX = "NetworkManager\-(?P<pver>1\.(\d*[02468])+\.(\d*[02468])+)\.tar.xz"

S = "${WORKDIR}/NetworkManager-${PV}"

EXTRA_OECONF = " \
    --disable-ifcfg-rh \
    --disable-more-warnings \
    --with-iptables=${sbindir}/iptables \
    --with-tests \
    --with-nmtui=yes \
    --with-udev-dir=${nonarch_base_libdir}/udev \
"

# stolen from https://github.com/void-linux/void-packages/blob/master/srcpkgs/NetworkManager/template
# avoids:
# | ../NetworkManager-1.16.0/libnm-core/nm-json.c:106:50: error: 'RTLD_DEEPBIND' undeclared (first use in this function); did you mean 'RTLD_DEFAULT'?
#
# and
#
# | In file included from ../NetworkManager-1.16.0/src/systemd/nm-sd-utils-core.c:25:
# | ../NetworkManager-1.16.0/src/systemd/sd-adapt-core/nm-sd-adapt-core.h:68:6: error: #error neither secure_getenv nor __secure_getenv is available
# |  #    error neither secure_getenv nor __secure_getenv is available
# |       ^~~~~
CFLAGS:append:libc-musl = " \
    -DRTLD_DEEPBIND=0 \
    -DHAVE_SECURE_GETENV \
    -Dsecure_getenv=getenv \
"

do_compile:prepend() {
    export GIR_EXTRA_LIBS_PATH="${B}/libnm/.libs:${B}/libnm-glib/.libs:${B}/libnm-util/.libs"
}

PACKAGECONFIG ??= "nss ifupdown dhclient dnsmasq \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd', bb.utils.contains('DISTRO_FEATURES', 'x11', 'consolekit', '', d), d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', 'bluez5', '', d)} \
    ${@bb.utils.filter('DISTRO_FEATURES', 'wifi polkit', d)} \
"
PACKAGECONFIG[systemd] = " \
    --with-systemdsystemunitdir=${systemd_unitdir}/system --with-session-tracking=systemd, \
    --without-systemdsystemunitdir, \
"
PACKAGECONFIG[polkit] = "--enable-polkit,--disable-polkit,polkit"
PACKAGECONFIG[bluez5] = "--enable-bluez5-dun,--disable-bluez5-dun,bluez5"
# consolekit is not picked by shlibs, so add it to RDEPENDS too
PACKAGECONFIG[consolekit] = "--with-session-tracking=consolekit,,consolekit,consolekit"
PACKAGECONFIG[modemmanager] = "--with-modem-manager-1=yes,--with-modem-manager-1=no,modemmanager"
PACKAGECONFIG[ppp] = "--enable-ppp --with-pppd-plugin-dir=${libdir}/pppd/2.4.7,--disable-ppp,ppp,ppp"
# Use full featured dhcp client instead of internal one
PACKAGECONFIG[dhclient] = "--with-dhclient=${base_sbindir}/dhclient,,,dhcp-client"
PACKAGECONFIG[dnsmasq] = "--with-dnsmasq=${bindir}/dnsmasq"
PACKAGECONFIG[nss] = "--with-crypto=nss,,nss"
PACKAGECONFIG[glib] = "--with-libnm-glib,,dbus-glib-native dbus-glib"
PACKAGECONFIG[gnutls] = "--with-crypto=gnutls,,gnutls"
PACKAGECONFIG[wifi] = "--enable-wifi=yes,--enable-wifi=no,,wpa-supplicant"
PACKAGECONFIG[ifupdown] = "--enable-ifupdown,--disable-ifupdown"
PACKAGECONFIG[qt4-x11-free] = "--enable-qt,--disable-qt,qt4-x11-free"

PACKAGES =+ "libnmutil libnmglib libnmglib-vpn \
  ${PN}-nmtui ${PN}-nmtui-doc \
  ${PN}-adsl \
"

FILES:libnmutil += "${libdir}/libnm-util.so.*"
FILES:libnmglib += "${libdir}/libnm-glib.so.*"
FILES:libnmglib-vpn += "${libdir}/libnm-glib-vpn.so.*"

FILES:${PN}-adsl = "${libdir}/NetworkManager/libnm-device-plugin-adsl.so"

FILES:${PN} += " \
    ${libexecdir} \
    ${libdir}/NetworkManager/dispatcher.d \
    ${libdir}/NetworkManager/system-connections \
    ${libdir}/NetworkManager/${PV}/*.so \
    ${nonarch_libdir}/NetworkManager/VPN \
    ${nonarch_libdir}/NetworkManager/conf.d \
    ${datadir}/polkit-1 \
    ${datadir}/dbus-1 \
    ${noarch_base_libdir}/udev/* \
    ${systemd_unitdir}/system \
    ${libdir}/pppd \
"

RRECOMMENDS:${PN} += "iptables \
    ${@bb.utils.filter('PACKAGECONFIG', 'dnsmasq', d)} \
"
RCONFLICTS:${PN} = "connman"

FILES:${PN}-dev += " \
    ${datadir}/NetworkManager/gdb-cmd \
    ${libdir}/pppd/*/*.la \
    ${libdir}/NetworkManager/*.la \
    ${libdir}/NetworkManager/${PV}/*.la \
"

FILES:${PN}-nmtui = " \
    ${bindir}/nmtui \
    ${bindir}/nmtui-edit \
    ${bindir}/nmtui-connect \
    ${bindir}/nmtui-hostname \
"

FILES:${PN}-nmtui-doc = " \
    ${mandir}/man1/nmtui* \
"

SYSTEMD_SERVICE:${PN} = "${@bb.utils.contains('PACKAGECONFIG', 'systemd', 'NetworkManager.service NetworkManager-dispatcher.service', '', d)}"

do_install:append() {
    rm -rf ${D}/run ${D}${localstatedir}/run
}
