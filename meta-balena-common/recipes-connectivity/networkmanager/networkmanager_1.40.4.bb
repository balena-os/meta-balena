SUMMARY = "NetworkManager"
HOMEPAGE = "https://wiki.gnome.org/Projects/NetworkManager"
SECTION = "net/misc"

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
                    file://docs/api/html/license.html;md5=0660fa481565243be23062c2fd524ccd \
"

DEPENDS = " \
    intltool-native \
    libxslt-native \
    libnl \
    libgudev \
    util-linux \
    libndp \
    libnewt \
    curl \
"

GNOMEBASEBUILDCLASS = "meson"
#inherit gnomebase gettext systemd bash-completion vala gobject-introspection gtk-doc
inherit gnomebase gettext systemd gobject-introspection gtk-doc update-alternatives upstream-version-is-even

SRC_URI = " \
    ${GNOME_MIRROR}/NetworkManager/${@gnome_verdir("${PV}")}/NetworkManager-${PV}.tar.xz \
    file://0001-Fixed-configure.ac-Fix-pkgconfig-sysroot-locations.patch \
"
SRC_URI:append:libc-musl = " \
    file://musl/0001-Fix-build-with-musl-systemd-specific.patch \
    file://musl/0002-Fix-build-with-musl.patch \
"
SRC_URI[sha256sum] = "b23214b5481c80f93f7515fcdeac11c09c8c96466872d7ec386d64fb5fd12cbf"

UPSTREAM_CHECK_URI = "${GNOME_MIRROR}/NetworkManager/${@gnome_verdir("${PV}")}/"
# Stable releases are numbered 1.y.z, with y and z being even numbers.
UPSTREAM_CHECK_REGEX = "NetworkManager\-(?P<pver>1\.(\d*[02468])+\.(\d*[02468])+)\.tar.xz"

S = "${WORKDIR}/NetworkManager-${PV}"

# ['auto', 'symlink', 'file', 'netconfig', 'resolvconf']
NETWORKMANAGER_DNS_RC_MANAGER_DEFAULT ??= "auto"

# ['dhcpcanon', 'dhclient', 'dhcpcd', 'internal', 'nettools']
NETWORKMANAGER_DHCP_DEFAULT ??= "internal"

#EXTRA_OECONF = " \
#    --disable-ifcfg-rh \
#    --disable-more-warnings \
#    --with-iptables=${sbindir}/iptables \
#    --with-tests \
#    --with-nmtui=yes \
#    --with-udev-dir=${nonarch_base_libdir}/udev \
#"

EXTRA_OEMESON = "\
    -Difcfg_rh=false \
    -Dtests=yes \
    -Dnmtui=true \
    -Dudev_dir=${nonarch_base_libdir}/udev \
    -Dlibpsl=false \
    -Dqt=false \
    -Dconfig_dns_rc_manager_default=${NETWORKMANAGER_DNS_RC_MANAGER_DEFAULT} \
    -Dconfig_dhcp_default=${NETWORKMANAGER_DHCP_DEFAULT} \
    -Ddhcpcanon=false \
"

# stolen from https://github.com/void-linux/void-packages/blob/master/srcpkgs/NetworkManager/template
# avoids:
# | ../NetworkManager-1.16.0/libnm-core/nm-json.c:106:50: error: 'RTLD_DEEPBIND' undeclared (first use in this function); did you mean 'RTLD_DEFAULT'?
CFLAGS:append:libc-musl = " \
    -DRTLD_DEEPBIND=0 \
"

do_compile:prepend() {
    export GI_TYPELIB_PATH="${B}}/src/libnm-client-impl${GI_TYPELIB_PATH:+:$GI_TYPELIB_PATH}"
}


PACKAGECONFIG ??= "readline nss ifupdown dnsmasq nmcli vala \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd', bb.utils.contains('DISTRO_FEATURES', 'x11', 'consolekit', '', d), d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', 'bluez5', '', d)} \
    ${@bb.utils.filter('DISTRO_FEATURES', 'wifi polkit', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'selinux audit', '', d)} \
"

inherit ${@bb.utils.contains('PACKAGECONFIG', 'vala', 'vala', '', d)}

PACKAGECONFIG[systemd] = "\
    -Dsystemdsystemunitdir=${systemd_unitdir}/system -Dsession_tracking=systemd,\
    -Dsystemdsystemunitdir=no -Dsystemd_journal=false -Dsession_tracking=no\
"
PACKAGECONFIG[polkit] = "-Dpolkit=true,-Dpolkit=false,polkit"
PACKAGECONFIG[bluez5] = "-Dbluez5_dun=true,-Dbluez5_dun=false,bluez5"
# consolekit is not picked by shlibs, so add it to RDEPENDS too
PACKAGECONFIG[consolekit] = "-Dsession_tracking_consolekit=true,-Dsession_tracking_consolekit=false,consolekit,consolekit"
PACKAGECONFIG[modemmanager] = "-Dmodem_manager=true,-Dmodem_manager=false,modemmanager mobile-broadband-provider-info"
PACKAGECONFIG[ppp] = "-Dppp=true -Dpppd=${sbindir}/pppd,-Dppp=false,ppp"
PACKAGECONFIG[dnsmasq] = "-Ddnsmasq=${bindir}/dnsmasq"
PACKAGECONFIG[nss] = "-Dcrypto=nss,,nss"
PACKAGECONFIG[resolvconf] = "-Dresolvconf=${base_sbindir}/resolvconf,-Dresolvconf=no,,resolvconf"
PACKAGECONFIG[gnutls] = "-Dcrypto=gnutls,,gnutls"
PACKAGECONFIG[crypto-null] = "-Dcrypto=null"
PACKAGECONFIG[wifi] = "-Dwext=true -Dwifi=true,-Dwext=false -Dwifi=false"
PACKAGECONFIG[iwd] = "-Diwd=true,-Diwd=false"
PACKAGECONFIG[ifupdown] = "-Difupdown=true,-Difupdown=false"
PACKAGECONFIG[cloud-setup] = "-Dnm_cloud_setup=true,-Dnm_cloud_setup=false"
PACKAGECONFIG[nmcli] = "-Dnmcli=true,-Dnmcli=false"
PACKAGECONFIG[readline] = "-Dreadline=libreadline,,readline"
PACKAGECONFIG[libedit] = "-Dreadline=libedit,,libedit"
PACKAGECONFIG[ovs] = "-Dovs=true,-Dovs=false,jansson"
PACKAGECONFIG[audit] = "-Dlibaudit=yes,-Dlibaudit=no"
PACKAGECONFIG[selinux] = "-Dselinux=true,-Dselinux=false,libselinux"
PACKAGECONFIG[vala] = "-Dvapi=true,-Dvapi=false"
PACKAGECONFIG[dhcpcd] = "-Ddhcpcd=yes,-Ddhcpcd=no,,dhcpcd"
PACKAGECONFIG[dhclient] = "-Ddhclient=yes,-Ddhclient=no,,dhcp"
PACKAGECONFIG[concheck] = "-Dconcheck=true,-Dconcheck=false"

PACKAGES =+ " \
    libnm \
    ${PN}-adsl \
    ${PN}-bluetooth \
    ${PN}-cloud-setup \
    ${PN}-nmcli \
    ${PN}-nmcli-bash-completion \
    ${PN}-nmtui \
    ${PN}-wifi \
    ${PN}-wwan \
    ${PN}-ovs \
    ${PN}-ppp \
    ${PN}-daemon \
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
    /usr/share/bash-completion/completions/nmcli \
"

RRECOMMENDS:${PN} += "iptables \
    ${@bb.utils.filter('PACKAGECONFIG', 'dnsmasq', d)} \
"
RCONFLICTS:${PN} = "connman"


SUMMARY:${PN}-ppp = "PPP plugin for NetworkManager"
FILES:${PN}-ppp = "\
    ${NETWORKMANAGER_PLUGINDIR}/libnm-ppp-plugin.so \
    ${libdir}/pppd/*/nm-pppd-plugin.so \
"
RDEPENDS:${PN}-ppp += "${PN}-daemon ${@bb.utils.contains('PACKAGECONFIG','ppp','ppp','',d)}"


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
