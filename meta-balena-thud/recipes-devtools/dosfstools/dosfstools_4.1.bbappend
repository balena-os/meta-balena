FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"

SRC_URI_append = " file://0001-src-check.c-Fix-up-mtools-created-bad-dir-entries.patch"
