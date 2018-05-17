FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"
SRC_URI_append = " \
    file://0001-tar-Fix-parsing-of-tar-archives-generated-by-docker.patch \
    file://0002-switch_root-don-t-bail-out-when-console-doesn-t-exis.patch \
    file://0003-switch_root-Fix-undefined-fd-and-minor-tweak.patch \
    "
