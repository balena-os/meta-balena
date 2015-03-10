SUMMARY = "Resin Package Groups"
LICENSE = "Apache-2.0"

PR = "r1"

inherit packagegroup

RESIN_INIT_PACKAGE ?= "resin-init"

RDEPENDS_${PN} = "\
	${@bb.utils.contains('DISTRO_FEATURES', 'resin-staging', 'nano', '', d)} \
	${RESIN_INIT_PACKAGE} \
	linux-firmware-ath9k \
	linux-firmware-ralink \
	linux-firmware-rtl8192cu \
	kernel-modules \
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
	tar \
	util-linux \
	socat \
	jq curl \
	resin-device-register \
	resin-device-progress \
	resin-device-update \
	supervisor-init \
	vpn-init \
	bridge-utils \
	"
