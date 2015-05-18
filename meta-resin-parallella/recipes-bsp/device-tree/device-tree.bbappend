FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI_append = " \
    file://led-control.patch;patchdir=${WORKDIR}/common \
    file://Fix-kernel-bootargs.patch;patchdir=${WORKDIR}/parallella \
    "
S = "${WORKDIR}"

DEPLOY_DIR_IMAGE := "${DEPLOY_DIR_IMAGE}/device-trees"

do_deploy_prepend() {
    install -d ${DEPLOY_DIR_IMAGE}
}
