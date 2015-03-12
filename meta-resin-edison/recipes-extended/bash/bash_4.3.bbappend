FILESEXTRAPATHS_append := "${THISDIR}/bash:"

SRC_URI += "file://cve-2014-6271.patch;striplevel=0 \
            file://cve-2014-7169.patch \
           "
