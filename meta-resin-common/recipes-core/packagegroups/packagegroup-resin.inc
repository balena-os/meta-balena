SUMMARY = "Resin Package Group"
LICENSE = "Apache-2.0"

PR = "r1"

inherit packagegroup

RESIN_STAGING_ADDONS = " \
    iozone3 \
    nano \
    alsa-utils \
    usbutils \
    i2c-tools \
    "

RESIN_ADDONS = "rsync"

RDEPENDS_${PN} = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'resin-staging', '${RESIN_STAGING_ADDONS}', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd-analyze', '', d)} \
    ${RESIN_INIT_PACKAGE} \
    ${RESIN_MOUNTS} \
    ${RESIN_REGISTER} \
    ${RESIN_ADDONS} \
    kernel-modules \
    os-release \
    "
