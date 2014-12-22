# Base this image on core-image-minimal
include recipes-core/images/core-image-minimal.bb

# Set custom Image type
IMAGE_FSTYPES_forcevariable = "beaglebone-sdimg"

IMAGE_INSTALL_append = "linux-firmware-ath9k linux-firmware-ralink linux-firmware-rtl8192cu wireless-tools parted lvm2 openssl \
			dosfstools e2fsprogs connman connman-client btrfs-tools apt docker-arm \
			tar util-linux socat jq curl beaglebone-flasher rsync util-linux-blkid kernel-modules \
			"
