FILESEXTRAPATHS_append := "${THISDIR}/${PN}"

# GCC 5 fix - already available in newer versions of pseudo
SRC_URI_append = " file://0001-Use-constant-initializer-for-static.patch"
