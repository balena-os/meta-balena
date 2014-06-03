# Base this image on rpi-hwup-image
include recipes-core/images/rpi-hwup-image.bb

IMAGE_FEATURES += "ssh-server-dropbear splash"
