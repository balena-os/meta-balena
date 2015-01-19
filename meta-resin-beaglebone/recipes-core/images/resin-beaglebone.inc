# Base this image on core-image-minimal
include recipes-core/images/core-image-minimal.bb

# Set custom Image type
IMAGE_FSTYPES_forcevariable = "beaglebone-sdimg"

# Image features
IMAGE_FEATURES_append = "read-only-rootfs \
			"
# Connman config
PACKAGECONFIG_append_pn-connman = "wifi 3g"

IMAGE_INSTALL_append = "linux-firmware-ath9k linux-firmware-ralink linux-firmware-rtl8192cu wireless-tools parted lvm2 openssl \
			dosfstools e2fsprogs connman connman-client btrfs-tools apt docker-arm \
			tar util-linux socat jq curl beaglebone-init rsync util-linux-blkid kernel-modules \
			resin-device-progress  resin-device-register resin-device-update \
			"
