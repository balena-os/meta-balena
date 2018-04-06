# Copyright 2016-2017 Resinio Ltd.
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

#
# Support for compressed binaries with UPX
#
# e.g. FILES_COMPRESS = "/path/bin1 /path/bin2 /path/bin3"
# Define what binaries that we find in the package tree will be compressed
# This variable's definition is MANDATORY if this class is used
# NOTE: path is relative to PKGD directory
#

FILES_COMPRESS ?= ""

DEPENDS_append = " upx-native"

UPX ?= "${STAGING_BINDIR_NATIVE}/upx"
UPX_ARGS ?= "--best -q"

find_and_compress() {
    # Sanity check
    if [ -z ${FILES_COMPRESS} ]; then
        bbdebug 1 "Binary compress class imported but FILES_COMPRESS variable was found empty."
    else
        #Compress
        for bin in ${FILES_COMPRESS}; do
            exec=${PKGD}$bin
            if [ -x $exec ]; then
                ${UPX} ${UPX_ARGS} "$exec"
            else
                bbfatal "$exec: Executable not found"
            fi
        done
    fi
}

PACKAGEBUILDPKGD += "find_and_compress"
