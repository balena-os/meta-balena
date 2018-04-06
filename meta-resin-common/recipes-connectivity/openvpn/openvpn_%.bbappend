# Copyright 2015-2018 Resinio Ltd.
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

FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"

RESIN_CONNECTABLE_SRCURI = " \
    file://ca.crt \
    file://resin.conf \
    file://prepare-openvpn \
    file://prepare-openvpn.service \
    file://openvpn.service \
    file://upscript.sh \
    file://downscript.sh \
    "

inherit useradd
USERADD_PACKAGES = "${PN}"
USERADD_PARAM_${PN} += "--system -d / -M --shell /bin/nologin openvpn"

SRC_URI_append = " ${@bb.utils.contains("RESIN_CONNECTABLE","1","${RESIN_CONNECTABLE_SRCURI}","",d)}"

RDEPENDS_${PN} += "${@bb.utils.contains("RESIN_CONNECTABLE","1","bash jq resin-unique-key sed","",d)}"

SYSTEMD_SERVICE_${PN} = "${@bb.utils.contains("RESIN_CONNECTABLE","1","openvpn.service prepare-openvpn.service","",d)}"

do_install_append() {
    if [ ${RESIN_CONNECTABLE} -eq 1 ]; then
        install -d ${D}${sysconfdir}/openvpn
        install -m 0755 ${WORKDIR}/resin.conf ${D}${sysconfdir}/openvpn/resin.conf
        install -m 0755 ${WORKDIR}/upscript.sh ${D}${sysconfdir}/openvpn/upscript.sh
        install -m 0755 ${WORKDIR}/downscript.sh ${D}${sysconfdir}/openvpn/downscript.sh
        install -m 0755 ${WORKDIR}/ca.crt ${D}${sysconfdir}/openvpn/ca.crt

        if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
            install -d ${D}${bindir}
            install -m 0755 ${WORKDIR}/prepare-openvpn ${D}${bindir}
            install -d ${D}${systemd_unitdir}/system
            install -c -m 0644 ${WORKDIR}/prepare-openvpn.service ${D}${systemd_unitdir}/system
            install -c -m 0644 ${WORKDIR}/openvpn.service ${D}${systemd_unitdir}/system
            sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
                -e 's,@SBINDIR@,${sbindir},g' \
                -e 's,@BINDIR@,${bindir},g' \
                ${D}${systemd_unitdir}/system/*.service
        fi
    fi
}
do_install[vardeps] += "DISTRO_FEATURES RESIN_CONNECTABLE"
