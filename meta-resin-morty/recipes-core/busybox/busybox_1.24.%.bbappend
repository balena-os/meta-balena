FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"
SRC_URI_append = " \
    file://0001-tar-Fix-parsing-of-tar-archives-generated-by-docker.patch \
    "
