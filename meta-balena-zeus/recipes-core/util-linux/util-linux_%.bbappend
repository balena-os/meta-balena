FILESEXTRAPATHS_prepend :=  "${THISDIR}/${PN}:"

SRC_URI_append = "file://lsblk-force-to-print-PKNAME-for-partition.patch"
