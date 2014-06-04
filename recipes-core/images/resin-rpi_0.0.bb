# Base this image on rpi-hwup-image
include recipes-core/images/rpi-hwup-image.bb

IMAGE_FEATURES += "ssh-server-dropbear splash"
#PACKAGE_INSTALL += "parted openssl sqlite3 tar dosfstools e2fsprogs"
VIDEO_CAMERA = "1"
IMAGE_INSTALL += "parted openssl sqlite3 dosfstools e2fsprogs connman"
