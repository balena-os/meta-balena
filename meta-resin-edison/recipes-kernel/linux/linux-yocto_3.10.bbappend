FILESEXTRAPATHS_append_edison := "${THISDIR}/files:"
SRC_URI_append_edison = " file://do_not_expose_mmc_boot_partitions.patch"

inherit kernel-resin
