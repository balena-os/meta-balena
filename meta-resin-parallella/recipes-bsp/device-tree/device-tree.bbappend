FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI_append_parallella-hdmi-resin = " \
    file://led-control.patch;patchdir=${WORKDIR}/common \
    file://Fix-kernel-bootargs.patch;patchdir=${WORKDIR}/parallella \
    "
S = "${WORKDIR}"

DEPLOY_DIR_IMAGE := "${DEPLOY_DIR_IMAGE}/device-trees"

do_deploy_prepend_parallella-hdmi-resin() {
    install -d ${DEPLOY_DIR_IMAGE}
}
