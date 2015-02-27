# Base this image on rpi-hwup-image
include recipes-core/images/rpi-hwup-image.bb
inherit classes/sdcard_image_resin-rpi.bbclass

VIDEO_CAMERA = "1"

IMAGE_FEATURES += "splash package-management ssh-server-dropbear"

IMAGE_INSTALL_append = " \
	linux-firmware-ath9k \
	linux-firmware-ralink \
	linux-firmware-rtl8192cu \
	wireless-tools \
	parted \
	lvm2 \
	openssl \
	dosfstools \
	e2fsprogs \
	connman \
	connman-client \
	btrfs-tools \
	apt \
	rce \
	rpi-init \
	tar \
	util-linux \
	socat \
	jq curl \
	resin-device-register \
	resin-device-progress \
	resin-device-update \
	supervisor-init \
	vpn-init \
	"
