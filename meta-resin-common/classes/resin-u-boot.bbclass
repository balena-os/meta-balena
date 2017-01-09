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
