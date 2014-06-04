# Base this image on rpi-hwup-image
include recipes-core/images/rpi-hwup-image.bb

IMAGE_FEATURES += "ssh-server-dropbear splash"
#PACKAGE_INSTALL += "parted openssl sqlite3 tar dosfstools e2fsprogs"
IMAGE_INSTALL += "parted openssl sqlite3 tar dosfstools e2fsprogs"
