# Base this image on core-image-minimal
include recipes-core/images/core-image-minimal.bb

IMAGE_FEATURES_append = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'resin-staging', 'debug-tweaks', '', d)} \
    splash \
    ssh-server-dropbear \
    "

IMAGE_INSTALL_append = " \
    packagegroup-resin-connectivity \
    packagegroup-resin \
    "
