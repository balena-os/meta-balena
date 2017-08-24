SUMMARY = "Resin Package Group"
LICENSE = "Apache-2.0"

PR = "r1"

inherit packagegroup

RDEPENDS_${PN} = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', bb.utils.contains('DISTRO_FEATURES', 'development-image', 'systemd-analyze', '', d), '', d)} \
    ${RESIN_INIT_PACKAGE} \
    ${RESIN_MOUNTS} \
    ${RESIN_REGISTER} \
    rsync \
    kernel-modules \
    os-release \
    "
