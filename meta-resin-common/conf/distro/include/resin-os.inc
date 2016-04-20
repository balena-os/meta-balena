# Poky based distro file - keep it at the end to be able to overwrite
require conf/distro/poky.conf

DISTRO = "resin-os"
DISTRO_NAME = "Resin OS"
DISTRO_VERSION = "1.1.4"

MAINTAINER = "Resin <hello@resin.io>"

# Strip down unneeded features
POKY_DEFAULT_DISTRO_FEATURES_remove = "ptest"
POKY_DEFAULT_DISTRO_FEATURES_remove = "wayland"
DISTRO_FEATURES_DEFAULT_remove = "x11"

RESIN_DEFAULT_DISTRO_FEATURES = "resin"
RESIN_STAGING_BUILD ?= ""
SUPERVISOR_TAG ?= "production"
DISTRO_FEATURES_append = " ${RESIN_DEFAULT_DISTRO_FEATURES} ${@bb.utils.contains('RESIN_STAGING_BUILD','yes','resin-staging','',d)}"

PREFERRED_PROVIDER_docker ?= "rce-armv6"
PREFERRED_PROVIDER_jpeg ?= "jpeg"
PREFERRED_PROVIDER_jpeg-native ?= "jpeg-native"
PREFERRED_PROVIDER_resin-supervisor ?= "resin-supervisor-disk"

SPLASH = "plymouth"

IMAGE_CLASSES += "image_types_resin host-update-resin"

# Define the URL where resin exposes source or prebuilt packages
AMAZON_RESIN_SHARE = "https://s3.amazonaws.com/resin-share/build_requirements"

# have build information available on the target under /etc/build
INHERIT += "image-buildinfo"
