FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI_append = " \
    file://led-control.patch;patchdir=${WORKDIR}/common \
    file://Fix-kernel-bootargs.patch;patchdir=${WORKDIR}/parallella \
    "
