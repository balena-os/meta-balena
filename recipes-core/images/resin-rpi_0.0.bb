# Base this image on rpi-hwup-image
include recipes-core/images/rpi-hwup-image.bb

IMAGE_FEATURES += "ssh-server-dropbear splash package-management"
#PACKAGE_INSTALL += "parted openssl sqlite3 tar dosfstools e2fsprogs"
VIDEO_CAMERA = "1"
IMAGE_INSTALL_append = "linux-firmware-ralink wireless-tools parted openssl dosfstools e2fsprogs connman connman-client strace btrfs-tools apt docker"
IMAGE_FSTYPES_forcevariable = "resin-rpi-sdimg tar.bz2"
PACKAGE_CLASSES_forcevariable = "package_deb"
