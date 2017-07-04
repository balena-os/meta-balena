FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"

SRC_URI_append = " file://0001-rules-add-dev-disk-by-partuuid-symlinks-also-for-dos.patch"
