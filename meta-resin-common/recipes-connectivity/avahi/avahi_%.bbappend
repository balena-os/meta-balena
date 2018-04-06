# Copyright 2016-2017 Resinio Ltd.
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

FILESEXTRAPATHS_append := ":${THISDIR}/files"

SRC_URI_append = " file://avahi-daemon.conf"

FILES_avahi-daemon += "${sysconfdir}/systemd/system/avahi-daemon.service.d/avahi-daemon.conf"

RDEPENDS_avahi-daemon += "resin-hostname"

do_install_append() {
    # Move example services as we don't want to advertise example services
    install -d ${D}/usr/share/doc/${PN}
    mv ${D}/etc/avahi/services/ssh.service ${D}/usr/share/doc/${PN}/
    mv ${D}/etc/avahi/services/sftp-ssh.service ${D}/usr/share/doc/${PN}/

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${sysconfdir}/systemd/system/avahi-daemon.service.d
        install -c -m 0644 ${WORKDIR}/avahi-daemon.conf ${D}${sysconfdir}/systemd/system/avahi-daemon.service.d
    fi
}
