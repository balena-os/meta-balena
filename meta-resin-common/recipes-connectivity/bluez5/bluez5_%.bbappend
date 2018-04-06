# Copyright 2017-2018 Resinio Ltd.
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

SRC_URI += " \
	file://10-local-bt-hci-up.rules \
	file://run-bluetoothd-with-experimental-flag.patch \
	"

do_install_append() {
    install -D -m 0755 ${WORKDIR}/10-local-bt-hci-up.rules ${D}/etc/udev/rules.d/10-local-bt-hci-up.rules
}
