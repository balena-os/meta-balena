FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI_append_zc702-zynq7 = " \
    file://zc702-add-led.patch \
    "
