FILESEXTRAPATHS:append := ":${BALENA_COREBASE}/recipes-bsp/u-boot/files"
FILESEXTRAPATHS:append := ":${BALENA_COREBASE}/recipes-bsp/u-boot/patches"

INTEGRATION_KCONFIG_PATCH = "file://resin-specific-env-integration-kconfig.patch"
INTEGRATION_NON_KCONFIG_PATCH = "file://resin-specific-env-integration-non-kconfig.patch"

# We require these uboot config options to be enabled for env_resin.h
SRC_URI += "file://balenaos_uboot.cfg"

SRC_URI += "${@bb.utils.contains('DISTRO_FEATURES', 'osdev-image', '', 'file://balenaos_uboot_prod.cfg', d)}"
SRC_URI += "${@bb.utils.contains('DISTRO_FEATURES', 'osdev-image', 'file://balenaos_uboot_delay.cfg', 'file://balenaos_uboot_nodelay.cfg', d)}"

# Machine independent patches
SRC_URI:append = " \
    file://env_resin.h \
    ${@bb.utils.contains('UBOOT_KCONFIG_SUPPORT', '1', '${INTEGRATION_KCONFIG_PATCH}', '${INTEGRATION_NON_KCONFIG_PATCH}', d)} \
    "

python __anonymous() {
    # Use different integration patch based on u-boot Kconfig support
    kconfig_support = d.getVar('UBOOT_KCONFIG_SUPPORT', True)
    if not kconfig_support or (kconfig_support != '0' and kconfig_support != '1'):
        bb.error("UBOOT_KCONFIG_SUPPORT not defined or wrong value. Should be 0 or 1.")
}

# A static patch won't apply to all u-boot versions, therefore
# we edit the sources to silent the console in production builds.
do_configure:append() {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'osdev-image', 'false', 'true', d)}; then
        if grep -qP "void puts\(const char \*s\)" ${S}/common/console.c ; then
            line=$(grep -nP "void puts\(const char \*s\)" ${S}/common/console.c | cut -f1 -d:)
            increment=0
            for iter in ${line}; do
                sed -i "$(expr ${iter} \+ 2 \+ ${increment}) i return;" ${S}/common/console.c
                increment=`expr $increment + 1`
            done
        else
            bbfatal "Failed to patch u-boot for silencing console in production!"
        fi;
    fi;
}


BALENA_BOOT_PART = "1"
BALENA_DEFAULT_ROOT_PART = "2"
BALENA_ENV_FILE = "resinOS_uEnv.txt"
BALENA_EXTRA_ENV_FILE = "extra_uEnv.txt"
BALENA_UBOOT_DEVICES ?= "0 1 2"
BALENA_UBOOT_DEVICE_TYPES ?= "mmc"

# OS_KERNEL_CMDLINE is a distro wide variable intended to be used in all the
# supported bootloaders
BASE_OS_CMDLINE ?= "${OS_KERNEL_CMDLINE}"
OS_BOOTCOUNT_FILE ?= "bootcount.env"
OS_BOOTCOUNT_SKIP ?= "0"
OS_BOOTCOUNT_LIMIT ?= "3"

# These options go into the device headerfile via config_resin.h
CONFIG_RESET_TO_RETRY ?= "1"
CONFIG_BOOT_RETRY_TIME ?= "${@bb.utils.contains('DISTRO_FEATURES', 'osdev-image', '-1', '15', d)}"

CONFIG_CMD_FS_UUID = "1"

UBOOT_VARS = "BALENA_UBOOT_DEVICES \
              BALENA_UBOOT_DEVICE_TYPES \
              BALENA_BOOT_PART BALENA_DEFAULT_ROOT_PART \
              BALENA_IMAGE_FLAG_FILE \
              BALENA_FLASHER_FLAG_FILE \
              BALENA_ENV_FILE \
              BALENA_EXTRA_ENV_FILE \
              BASE_OS_CMDLINE \
              OS_BOOTCOUNT_FILE \
              OS_BOOTCOUNT_SKIP \
              OS_BOOTCOUNT_LIMIT \
              CONFIG_RESET_TO_RETRY \
              CONFIG_BOOT_RETRY_TIME \
              CONFIG_CMD_IMPORTENV \
              CONFIG_CMD_FS_UUID "

python do_generate_resin_uboot_configuration () {
    vars = d.getVar('UBOOT_VARS').split()
    with open(os.path.join(d.getVar('S'), 'include', 'config_resin.h'), 'w') as f:
        for v in vars:
            f.write("#define %s %s\n" % (v, d.getVar(v)))

    src = bb.utils.which(d.getVar('FILESPATH'), 'env_resin.h')
    if not src:
        raise Exception('env_resin.h not found')
    dst = os.path.join(d.getVar('S'), 'include', 'env_resin.h')
    bb.utils.copyfile(src, dst)
}
addtask do_generate_resin_uboot_configuration after do_patch before do_configure

# Regenerate env_resin.h if any of these variables change.
do_generate_resin_uboot_configuration[vardeps] += "${UBOOT_VARS}"

# u-boot has config options in two places. In the devices config header
# and once via the devices defconfig file. We'd like to be able to
# inject config options in both places. We include config_resin in
# config_default to be able to inject config options that aren't
# changeable via Kconfig and config fragments.
do_inject_config_resin () {
    sed -i '/^#endif.*/i #include <config_resin.h>' ${S}/include/config_defaults.h || true
}

do_deploy:append() {
    touch ${DEPLOYDIR}/extra_uEnv.txt
}

addtask do_inject_config_resin after do_configure before do_compile
do_inject_config_resin[vardeps] += "${UBOOT_VARS}"
