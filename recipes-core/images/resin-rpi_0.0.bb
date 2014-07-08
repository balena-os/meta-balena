# Base this image on rpi-hwup-image
include recipes-core/images/rpi-hwup-image.bb

IMAGE_FEATURES += "splash package-management"
VIDEO_CAMERA = "1"
IMAGE_INSTALL_append = "linux-firmware-ath9k linux-firmware-ralink linux-firmware-rtl8192cu wireless-tools parted lvm2 openssl dosfstools e2fsprogs connman connman-client btrfs-tools apt docker-arm rpi-init tar supervisor-init"
IMAGE_FSTYPES_forcevariable = "resin-noobs"
