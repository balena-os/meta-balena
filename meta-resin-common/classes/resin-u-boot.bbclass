# Copyright 2017 Resinio Ltd.
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

FILESEXTRAPATHS_append := ":${RESIN_COREBASE}/recipes-bsp/u-boot/patches"

INTEGRATION_KCONFIG_PATCH = "file://resin-specific-env-integration-kconfig.patch"
INTEGRATION_NON_KCONFIG_PATCH = "file://resin-specific-env-integration-non-kconfig.patch"

# Machine independent patches
SRC_URI_append = " \
    file://resin-specific-env-configuration.patch \
    ${@bb.utils.contains('UBOOT_KCONFIG_SUPPORT', '1', '${INTEGRATION_KCONFIG_PATCH}', '${INTEGRATION_NON_KCONFIG_PATCH}', d)} \
    "

python __anonymous() {
    # Use different integration patch based on u-boot Kconfig support
    kconfig_support = d.getVar('UBOOT_KCONFIG_SUPPORT', True)
    if not kconfig_support or (kconfig_support != '0' and kconfig_support != '1'):
        bb.error("UBOOT_KCONFIG_SUPPORT not defined or wrong value. Should be 0 or 1.")
}

RESIN_BOOT_PART = "1"
RESIN_DEFAULT_ROOT_PART = "2"
RESIN_ENV_FILE = "resinOS_uEnv.txt"
RESIN_UBOOT_DEVICES ?= "0 1 2"

do_generate_resin_uboot_configuration () {
    cat > ${S}/include/config_resin.h <<EOF
#define RESIN_UBOOT_DEVICES ${RESIN_UBOOT_DEVICES}
#define RESIN_BOOT_PART ${RESIN_BOOT_PART}
#define RESIN_DEFAULT_ROOT_PART ${RESIN_DEFAULT_ROOT_PART}
#define RESIN_IMAGE_FLAG_FILE ${RESIN_IMAGE_FLAG_FILE}
#define RESIN_FLASHER_FLAG_FILE ${RESIN_FLASHER_FLAG_FILE}
#define RESIN_ENV_FILE ${RESIN_ENV_FILE}
EOF
}
addtask do_generate_resin_uboot_configuration after do_patch before do_configure
