include resin-beaglebone.inc

# Get some specific configuration for staging/production build
IMAGE_FEATURES_append = " ${@bb.utils.contains('DISTRO_FEATURES', 'resin-staging', 'debug-tweaks', '', d)}"
IMAGE_INSTALL_append = " ${@bb.utils.contains('DISTRO_FEATURES', 'resin-staging', 'nano top', '', d)}"
