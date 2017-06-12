# Poky based distro file
require conf/distro/poky.conf

DISTRO = "resin-os"
DISTRO_NAME = "Resin OS"
DISTRO_VERSION = "2.0.6"
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

MAINTAINER = "Resin <hello@resin.io>"

# Strip down unneeded features
POKY_DEFAULT_DISTRO_FEATURES_remove = "ptest"
POKY_DEFAULT_DISTRO_FEATURES_remove = "wayland"
DISTRO_FEATURES_DEFAULT_remove = "x11"

# Development image mode
DEVELOPMENT_IMAGE ?= "0"
DISTRO_FEATURES_append = " ${@bb.utils.contains('DEVELOPMENT_IMAGE','1','development-image','',d)}"

# By default preloads supervisor image
PREFERRED_PROVIDER_docker-disk ?= "docker-resin-supervisor-disk"

# Providers
PREFERRED_PROVIDER_docker ?= "docker"
PREFERRED_PROVIDER_jpeg ?= "jpeg"
PREFERRED_PROVIDER_jpeg-native ?= "jpeg-native"

SPLASH = "plymouth"

IMAGE_CLASSES += "image_types_resin"

# Define the URL where resin exposes source or prebuilt packages
AMAZON_RESIN_SHARE = "https://s3.amazonaws.com/resin-share/build_requirements"

# have build information available on the target under /etc/build
INHERIT += "image-buildinfo"

# we want our custom version with no TCL dependency
PREFERRED_VERSION_usb-modeswitch ?= "2.2.5"

# Identification file flags
RESIN_IMAGE_FLAG_FILE = "resin-image"
RESIN_FLASHER_FLAG_FILE = "resin-image-flasher"

# Initramfs
INITRAMFS_IMAGE = "resin-image-initramfs"
INITRAMFS_IMAGE_BUNDLE = "1"
KERNEL_INITRAMFS = "-initramfs"
