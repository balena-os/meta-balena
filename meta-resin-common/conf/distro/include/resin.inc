# Poky based distro file - keep it at the end to be able to overwrite
require conf/distro/poky.conf

DISTRO = "resin"
DISTRO_NAME = "Resin (Yocto Project Resin Distro)"

MAINTAINER = "Resin <hello@resin.io>"

RESIN_DEFAULT_DISTRO_FEATURES = "resin"
RESIN_STAGING_BUILD ?= ""
DISTRO_FEATURES_append = " ${RESIN_DEFAULT_DISTRO_FEATURES} ${@bb.utils.contains('RESIN_STAGING_BUILD','yes','resin-staging','',d)}"

PREFERRED_PROVIDER_rce ?= "rce-armv6"
PREFERRED_PROVIDER_jpeg ?= "jpeg"
PREFERRED_PROVIDER_jpeg-native ?= "jpeg-native"

# Use ths resin splash image package
SPLASH = "psplash-resin"

IMAGE_CLASSES += "image_types_resin"
