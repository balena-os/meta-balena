FILESEXTRAPATHS_prepend := "${THISDIR}/config:"
SRC_URI_append = " \
    file://rce.cfg \
    file://device_drivers.cfg \
    "
KERNEL_CONFIG_FRAGMENTS_append = " \
    ${WORKDIR}/rce.cfg \
    ${WORKDIR}/device_drivers.cfg \
    "
