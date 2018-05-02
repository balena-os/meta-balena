# Copyright 2018 Resinio Ltd.
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

DESCRIPTION = "Initialize system clock at boot"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://timeinit-rtc.service \
    file://timeinit-timestamp.service \
    file://timeinit-timestamp.sh \
    "
S = "${WORKDIR}"

inherit allarch systemd

SYSTEMD_SERVICE_${PN} = " \
	timeinit-rtc.service \
	timeinit-timestamp.service \
	"

do_install() {
    install -d ${D}${bindir}
    install -d ${D}${systemd_unitdir}/system
    install -m 0775 ${WORKDIR}/timeinit-timestamp.sh ${D}${bindir}
    install -c -m 0644 ${WORKDIR}/timeinit-timestamp.service ${D}${systemd_unitdir}/system
    install -c -m 0644 ${WORKDIR}/timeinit-rtc.service ${D}${systemd_unitdir}/system
}
