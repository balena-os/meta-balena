FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += " \
	file://u-boot-default-mmcdev1.patch \
	file://beaglebone_MMC_ENV_DISABLE.patch \
	"
