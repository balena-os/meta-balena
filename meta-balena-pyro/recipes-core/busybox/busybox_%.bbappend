FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI_append = " \
    file://0001-switch_root-don-t-bail-out-when-console-doesn-t-exis.patch \
    file://0002-switch_root-Fix-undefined-fd-and-minor-tweak.patch \
    "
