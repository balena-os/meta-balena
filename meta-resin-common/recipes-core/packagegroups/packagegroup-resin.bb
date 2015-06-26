SUMMARY = "Resin Package Group"
LICENSE = "Apache-2.0"

PR = "r1"

inherit packagegroup

RESIN_INIT_PACKAGE ?= "resin-init"
RESIN_STAGING_ADDONS = "iozone3 nano"

RDEPENDS_${PN} = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'resin-staging', '${RESIN_STAGING_ADDONS}', '', d)} \
    ${RESIN_INIT_PACKAGE} \
    kernel-modules \
    parted \
    lvm2 \
    openssl \
    dosfstools \
    e2fsprogs \
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
    resin-btrfs-balance \
    supervisor-init \
    bridge-utils \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd-analyze', '', d)} \
    "
