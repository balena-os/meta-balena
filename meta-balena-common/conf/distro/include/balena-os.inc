# Poky based distro file
require conf/distro/poky.conf
include conf/distro/include/balena-os-yocto-version.inc
include conf/distro/include/balena-os-rust-version.inc

DISTRO = "balena-os"
DISTRO_NAME = "balenaOS"
DISTRO_VERSION = "6.6.10"
HOSTOS_VERSION = "${DISTRO_VERSION}"
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
PACKAGE_CLASSES ?= "package_ipk"

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

# let's pin linux-firmware to the version we imported from Poky kirkstone release
PREFERRED_VERSION_linux-firmware = "20230404"

# balena-engine go version requirement
GOVERSION = "1.17.13"
PREFERRED_PROVIDER_go-native = "go-native"

# Firmware compression support
FIRMWARE_COMPRESSION ?= "0"

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
