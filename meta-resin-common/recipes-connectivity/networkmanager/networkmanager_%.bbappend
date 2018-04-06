# Copyright 2016-2018 Resinio Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

inherit deploy bash-completion

DEPENDS += "curl"

FILESEXTRAPATHS_append := ":${THISDIR}/files"

SRC_URI_append = " \
    file://NetworkManager.conf.systemd \
    file://NetworkManager.conf \
    file://README.ignore \
    file://resin-sample.ignore \
    file://nm-tmpfiles.conf \
    "

RDEPENDS_${PN}_append = " resin-net-config resolvconf"
FILES_${PN}_append = "${sysconfdir}/*"
EXTRA_OECONF += " \
    --with-resolvconf=/sbin/resolvconf \
    --disable-ovs \
    "
PACKAGECONFIG_append = " systemd modemmanager ppp"

# we disable introspection as we do not use it and it also fails to compile (on poky krogoth/morty) if we don't disable it or if we don't inherit gobject-introspection
# (we don't want to inherit gobject-introspection for compatibility reasons with regards to older poky versions which do not have the gobject-introspection.bbclass)
PACKAGECONFIG[introspection] = "--enable-introspection=no,,,"
PACKAGECONFIG_append = " introspection"

do_install_append() {
    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 0644 ${WORKDIR}/nm-tmpfiles.conf ${D}${sysconfdir}/tmpfiles.d/

    install -m 0644 ${WORKDIR}/NetworkManager.conf ${D}${sysconfdir}/NetworkManager/

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${sysconfdir}/systemd/system/NetworkManager.service.d
        install -m 0644 ${WORKDIR}/NetworkManager.conf.systemd ${D}${sysconfdir}/systemd/system/NetworkManager.service.d/NetworkManager.conf
    fi

    ln -s /var/run/resolvconf/interface/NetworkManager ${D}/etc/resolv.dnsmasq

    # remove these empty not-used (at this moment) directories so we don't have to package them
    rmdir ${D}${libdir}/NetworkManager/conf.d
    rmdir ${D}${libdir}/NetworkManager/VPN
}

do_deploy() {
    mkdir -p "${DEPLOYDIR}/system-connections/"
    install -m 0600 "${WORKDIR}/resin-sample.ignore" "${DEPLOYDIR}/system-connections/"
    install -m 0600 "${WORKDIR}/README.ignore" "${DEPLOYDIR}/system-connections/"
}

addtask deploy before do_package after do_install
