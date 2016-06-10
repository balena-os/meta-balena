# Poky based distro file - keep it at the end to be able to overwrite
require conf/distro/poky.conf

DISTRO = "resin-os"
DISTRO_NAME = "Resin OS"
DISTRO_VERSION = "1.2"
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
            board_version = v.read()
        d.setVar('HOSTOS_VERSION', board_version)
    except:
        return
}

MAINTAINER = "Resin <hello@resin.io>"

# Strip down unneeded features
POKY_DEFAULT_DISTRO_FEATURES_remove = "ptest"
POKY_DEFAULT_DISTRO_FEATURES_remove = "wayland"
DISTRO_FEATURES_DEFAULT_remove = "x11"

RESIN_DEFAULT_DISTRO_FEATURES = "resin"
RESIN_STAGING_BUILD ?= ""
SUPERVISOR_TAG ?= "production"
DISTRO_FEATURES_append = " ${RESIN_DEFAULT_DISTRO_FEATURES} ${@bb.utils.contains('RESIN_STAGING_BUILD','yes','resin-staging','',d)}"

PREFERRED_PROVIDER_docker ?= "docker"
PREFERRED_PROVIDER_jpeg ?= "jpeg"
PREFERRED_PROVIDER_jpeg-native ?= "jpeg-native"

CUSTOM_PRELOADED_DOCKER_IMAGE ?= "no"
PREFERRED_PROVIDER_docker-disk = "${@bb.utils.contains('CUSTOM_PRELOADED_DOCKER_IMAGE','yes','docker-custom-disk','docker-resin-supervisor-disk',d)}"

SPLASH = "plymouth"

IMAGE_CLASSES += "image_types_resin host-update-resin"

# Define the URL where resin exposes source or prebuilt packages
AMAZON_RESIN_SHARE = "https://s3.amazonaws.com/resin-share/build_requirements"

# have build information available on the target under /etc/build
INHERIT += "image-buildinfo"
