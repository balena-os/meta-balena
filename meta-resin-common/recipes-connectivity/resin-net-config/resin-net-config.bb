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

DESCRIPTION = "resin network management configuration"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r1.1"

SRC_URI = " \
    file://resin-net-config \
    file://resin-net-config.service \
    "
S = "${WORKDIR}"

inherit allarch systemd

PACKAGES = "${PN} ${PN}-flasher"

SYSTEMD_SERVICE_${PN} = "resin-net-config.service"
RDEPENDS_${PN} = "bash jq iw"

do_install() {
    install -d ${D}${bindir}
    install -m 0775 ${WORKDIR}/resin-net-config ${D}${bindir}/resin-net-config

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/resin-net-config.service ${D}${systemd_unitdir}/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
        -e 's,@BINDIR@,${bindir},g' \
            ${D}${systemd_unitdir}/system/resin-net-config.service
    fi
}
