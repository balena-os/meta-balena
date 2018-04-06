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

DESCRIPTION = "redsocks - transparent socks redirector"
SECTION = "net/misc"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM="file://README;beginline=74;endline=78;md5=edd3a93090d9025f47a1fdec44ace593"

SRCREV = "27b17889a43e32b0c1162514d00967e6967d41bb"

SRC_URI = " \
    git://github.com/darkk/redsocks.git \
    file://0001-using-libevent-2_1_x.patch \
"

DEPENDS = "libevent"

S = "${WORKDIR}/git"

do_install () {
    install -d ${D}${bindir}
    install -m 0775 ${S}/redsocks ${D}${bindir}/redsocks
}
