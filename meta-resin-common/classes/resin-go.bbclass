# Copyright 2016 Resinio Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

inherit go

do_compile_prepend() {
    export CGO_ENABLED=0
}

# Fix host-user-contaminated
do_install_append() {
    chown root:root -R ${D}

    # Install all binaries in bindir
    if [ -d "${D}${GOROOT_FINAL}/bin"  ]; then
        mkdir -p ${D}${bindir}
        find ${D}${GOROOT_FINAL}/bin -type f -exec mv '{}' ${D}${bindir} \;
        rm -rf ${D}${GOROOT_FINAL}/bin
    fi
}

FILES_${PN} += "${bindir}"
