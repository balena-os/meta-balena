FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI_append_zc702-zynq7 = " \
    file://zc702-add-led.patch \
    "
S = "${WORKDIR}"

DEPLOY_DIR_IMAGE := "${DEPLOY_DIR_IMAGE}/device-trees"
