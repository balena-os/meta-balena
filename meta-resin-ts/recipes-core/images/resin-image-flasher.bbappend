include resin-image.inc

#
# ts4900
#

RDEPENDS_${PN}_append_ts4900 = " u-boot-script-ts"

RESIN_BOOT_PARTITION_FILES_append_ts4900 = " \
     u-boot.imx: \
     boot.ub:/boot/boot.ub \
     "
