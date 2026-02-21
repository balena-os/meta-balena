# Poky based distro file
require conf/distro/poky.conf
include conf/distro/include/balena-os-yocto-version.inc
include conf/distro/include/balena-os-rust-version.inc

DISTRO = "balena-os"
DISTRO_NAME = "balenaOS"
DISTRO_VERSION = "6.11.0"
HOSTOS_VERSION = "${DISTRO_VERSION}"

# This list of packages is common for all
# meta-balena-<yocto_release> layers
COMMON_CONNECTIVITY_FIRMWARES = " \
    linux-firmware-bcm43143 \
    linux-firmware-iwlwifi-135-6 \
    linux-firmware-iwlwifi-3160 \
    linux-firmware-iwlwifi-6000-4 \
    linux-firmware-iwlwifi-6000g2a-6 \
    linux-firmware-iwlwifi-6000g2b-6 \
    linux-firmware-iwlwifi-6050-5 \
    linux-firmware-iwlwifi-7260 \
    linux-firmware-iwlwifi-7265 \
    linux-firmware-iwlwifi-7265d \
    linux-firmware-iwlwifi-8000c \
    linux-firmware-iwlwifi-8265 \
    linux-firmware-rtl8188eu \
    linux-firmware-wl12xx \
"

# This list is set by meta-balena-common
CORE_CONNECTIVITY_FIRMWARES = " \
    linux-firmware-ath9k \
    linux-firmware-mt7601u \
    linux-firmware-ralink \
    linux-firmware-rtl8192cu \
    linux-firmware-rtl8192su \
    linux-firmware-rtl8723 \
    ${COMMON_CONNECTIVITY_FIRMWARES} \
"

# Firmware packages which are used by
# wifi modules with an M.2 interface
LINUX_FIRMWARE_PACKAGES[pci] ?= " \
    linux-firmware-iwlwifi-9260 \
    linux-firmware-iwlwifi-3160 \
    linux-firmware-iwlwifi-7260 \
    linux-firmware-iwlwifi-7265d \
    linux-firmware-iwlwifi-7265 \
    linux-firmware-iwlwifi-8000c \
    linux-firmware-iwlwifi-8265 \
    linux-firmware-rtl8723 \
    linux-firmware-iwlwifi-7260 \
    linux-firmware-iwlwifi-7265d \
    linux-firmware-iwlwifi-7265 \
    linux-firmware-iwlwifi-8000c \
    linux-firmware-iwlwifi-8265 \
    linux-firmware-rtl8723 \
"

# Firmware packages used by wifi modules
# that use SDIO or UART. The wifi chip
# usually comes soldered in this case.
LINUX_FIRMWARE_PACKAGES[sdio] ?= " \
    linux-firmware-iwlwifi-8265 \
    linux-firmware-rtl8723 \
"

# Firmware packages for modules which use a
# Half MINI PCIE interface
LINUX_FIRMWARE_PACKAGES[pci] ?= " \
    linux-firmware-iwlwifi-6000-4 \
    linux-firmware-iwlwifi-6000g2a-6 \
    linux-firmware-iwlwifi-6000g2b-6 \
    linux-firmware-iwlwifi-6050-5 \
    linux-firmware-iwlwifi-7260 \
    linux-firmware-iwlwifi-135-6 \
    linux-firmware-rtl8723 \
"

# Firmware packages for USB wifi dongles
LINUX_FIRMWARE_PACKAGES[usbhost] ?= " \
    linux-firmware-ath9k \
    linux-firmware-rtl8723 \
    linux-firmware-ralink \
    linux-firmware-bcm43143 \
    linux-firmware-rtl8192cu \
    linux-firmware-mt7601u \
    linux-firmware-rtl8188eu \
"

# Firmware packages for PCIE Wifi adapters
LINUX_FIRMWARE_PACKAGES[pci] ?= " \
    linux-firmware-ath9k  \
"

# Firmware packages for mini PCIE Wifi adapters
LINUX_FIRMWARE_PACKAGES[pci] ?= " \
    linux-firmware-ath9k \
    linux-firmware-ralink \
"

# Firmware packages used by the TI WiLink8 WL1835MOD / 1837MOD
# wifi chipsets. These are not detachable
# from the device, they are soldered.
# Commonly used by Beaglebone boards
LINUX_FIRMWARE_PACKAGES[features_TI_WiLink8] ?= " \
    linux-firmware-wl18xx \
    linux-firmware-wlcommon \
"

# Firmware for TI wilink 6.0 / 7.0 - WL1271 / WL1273
# wifi chipsets, used on the VAR-SOM-MX6 and BeagleXM
LINUX_FIRMWARE_PACKAGES[features_TI_WiLink_6_7] ?= " \
    linux-firmware-wl12xx \
"

# Firmware for the Realtek RTL8192SU chipset,
# found in USB dongles. Has been discontinued
# since 2012 and can only be purchased from
# pulled parts.
LINUX_FIRMWARE_PACKAGES[rtl8192su] ?= " \
    linux-firmware-rtl8192su \
"

# Allowed kernel cmdline arguments, used by balena-bootloader and the bootloader configuration scripts
ALLOWED_BOOTARGS_LIST=" \
    firmware_class.path=/var/lib/docker/volumes/extra-firmware/_data \
"

# Provides a bash array from the above allowed boot args list
def format_bootargs_array(d):
    args_list = d.getVar('ALLOWED_BOOTARGS_LIST', False, False).split()
    quoted_args = [f'\\"{arg}\\"' for arg in args_list]
    joined_args = ' '.join(quoted_args)
    bash_array_str = '(' + joined_args + ')'
    return bash_array_str

python () {
    ''' Set HOSTOS_VERSION from board VERSION if available '''

    # Find board VERSION location based on poky meta layer
    bblayers = d.getVar('BBLAYERS', True).split()
    poky = [layer for layer in bblayers if layer.endswith('poky/meta')]
    if not poky:
        return
    board_version_path = os.path.join(poky[0], '../../../', 'VERSION')

    # Set HOSTOS_VERSION
    try:
        with open(board_version_path, 'r') as v:
            board_version = v.read().strip()
        d.setVar('HOSTOS_VERSION', board_version)
    except:
        return
}

def set_default_kernel_cmdline(d):
    cmdline = 'console=null quiet splash vt.global_cursor_default=0 consoleblank=0'
    if d.getVar('OS_DEVELOPMENT', True) is '1':
        cmdline = ""
        earlycon = d.getVar('EARLY_SERIAL_CONSOLE', True)
        if earlycon is not None:
            cmdline = "earlycon=" + earlycon
        for serial_console in d.getVar('SERIAL_CONSOLES', True).split():
            try:
                baudrate,port = serial_console.split(';')
                console = "console=" + port + "," + baudrate + "n8"
                if len(cmdline) is 0:
                    cmdline = console
                else:
                    cmdline = cmdline + " " + console
            except:
                return
    return cmdline

MAINTAINER = "Balena <hello@balena.io>"

# Strip down unneeded features
POKY_DEFAULT_DISTRO_FEATURES:remove = "ptest"
POKY_DEFAULT_DISTRO_FEATURES:remove = "wayland"
DISTRO_FEATURES_DEFAULT:remove = "x11"

# OS development image
OS_DEVELOPMENT ?= "0"
DISTRO_FEATURES:append = " ${@bb.utils.contains('OS_DEVELOPMENT','1','osdev-image','',d)}"

PARTITION_TABLE_TYPE ?= "msdos"

# Disable user namespacing with a sysctl by default, but allow DTs to leave it enabled
DISTRO_FEATURES:append = " disable-user-ns"

# balenaOS does not use PAM but some vendor BSP might add it
DISTRO_FEATURES:remove = "pam"

# Providers
PREFERRED_PROVIDER_docker ?= "docker"
PREFERRED_PROVIDER_jpeg ?= "jpeg"
PREFERRED_PROVIDER_jpeg-native ?= "jpeg-native"

SPLASH = "plymouth"

IMAGE_CLASSES += "image_types_balena"

# Define the URL where resin exposes source or prebuilt packages
AMAZON_BALENA_SHARE = "https://s3.amazonaws.com/resin-share/build_requirements"

# have build information available on the target under /etc/build
INHERIT += "image-buildinfo resin-sanity"

# Identification file flags
BALENA_IMAGE_FLAG_FILE = "balena-image"
BALENA_FLASHER_FLAG_FILE = "balena-image-flasher"

# Kernel command line
OS_KERNEL_CMDLINE ?= "${@set_default_kernel_cmdline(d)}"
OS_KERNEL_SECUREBOOT_CMDLINE ?= "module.sig_enforce lockdown=integrity"

# Initramfs
INITRAMFS_IMAGE = "balena-image-initramfs"
INITRAMFS_IMAGE_BUNDLE = "1"
KERNEL_INITRAMFS = "-initramfs"
INITRAMFS_TASK = ""
IMAGE_NAME_SUFFIX = ""

# resinOS defaults to ipk packages
PACKAGE_CLASSES = "package_ipk"

# Default the docker storage driver to aufs
BALENA_STORAGE = "overlay2"
python () {
    docker_storage = d.getVar('DOCKER_STORAGE', True)
    if docker_storage:
        d.setVar('BALENA_STORAGE', docker_storage)
}

# Partition fingerprints files
BALENA_FINGERPRINT_EXT ?= "fingerprint"
BALENA_FINGERPRINT_FILENAME ?= "balenaos"

# Hostname is generated at runtime based on config.json
hostname:pn-base-files = ""

BAD_RECOMMENDATIONS += "shared-mime-info"

# ARM data -> instruction cache consistency bug in latest UPX
# Downgrade to avoid this bug
# https://github.com/upx/upx/issues/225
PREFERRED_VERSION_upx:arm = "3.94"
PREFERRED_VERSION_upx-native:arm = "3.94"

# let's pin linux-firmware to the version we imported from Poky scarthgap release
PREFERRED_VERSION_linux-firmware = "20240909"

# Scarthgap go version, meets balena-engine go version requirement
GOVERSION = "1.22.12"
PREFERRED_PROVIDER_go-native = "go-binary-native"

# Firmware compression support
FIRMWARE_COMPRESSION ?= "1"

SIGN_API ?= ""
# Signing keys
SIGN_GRUB_KEY_ID ?= "2EB29B4CE0132F6337897F5FB8A88D1C62FCC729"
SIGN_KMOD_KEY_ID ?= "balenaos-kmod"
SIGN_KMOD_KEY_APPEND ?= ""
SIGN_EFI_PK_KEY_ID ?= "balenaos-pk"
SIGN_EFI_KEK_KEY_ID ?= "balenaos-kek"

# Default cloud API environment
BALENA_API_ENV ?= "balena-cloud.com"

# Default storage of configuration units
BALENA_CONF_UNIT_STORE ?= "/var/volatile"

# For systems that encrypt disks, label for the non-encrypted boot partition
BALENA_BOOT_LABEL ?= "balena-boot"
BALENA_BOOT_MOUNT ?= "/mnt/${@'${BALENA_BOOT_LABEL}'.replace('balena-','')}"
BALENA_SIGN_LABEL ?= "${@bb.utils.contains('MACHINE_FEATURES', 'efi', 'balena-efi', "${BALENA_BOOT_LABEL}",d)}"
BALENA_NONENC_BOOT_LABEL ?= "${@oe.utils.conditional('SIGN_API','','${BALENA_BOOT_LABEL}','${BALENA_SIGN_LABEL}',d)}"
BALENA_NONENC_BOOT_MOUNT ?= "/mnt/${@'${BALENA_NONENC_BOOT_LABEL}'.replace('balena-','')}"
BALENA_USE_LUKS ?= "1"

# This is the docker API version for v20.10
# balena version --format '{{.Server.APIVersion}}'
BALENA_API_VERSION ?= "1.41"
