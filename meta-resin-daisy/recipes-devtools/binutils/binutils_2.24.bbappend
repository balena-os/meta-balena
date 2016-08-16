FILESEXTRAPATHS_append := ":${THISDIR}/${PN}-${PV}"
SRC_URI_append = " file://binutils-2.24-i386-logical-not.patch"
