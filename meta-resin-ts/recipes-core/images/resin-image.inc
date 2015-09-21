#
# ts4900
#

IMAGE_FSTYPES_ts4900 = "resin-sdcard"

# We burn the FPGA bitstream in uboot so we need it in boot partition
RDEPENDS_${PN}_append_ts4900 = " ts4900-fpga"

# Customize resin-sdcard
RESIN_BOOT_PARTITION_FILES_ts4900 = " \
    ${KERNEL_IMAGETYPE}-${MACHINE}.bin:${KERNEL_IMAGETYPE} \
    uImage-imx6dl-ts4900.dtb:imx6dl-ts4900.dtb \
    uImage-imx6q-ts4900.dtb:imx6q-ts4900.dtb \
    uImage-imx6q-ts4900-2.dtb:imx6q-ts4900-2.dtb \
    uImage-imx6dl-ts4900-2.dtb:imx6dl-ts4900-2.dtb \
    uImage-imx6q-ts4900-9.dtb:imx6q-ts4900-9.dtb \
    uImage-imx6dl-ts4900-9.dtb:imx6dl-ts4900-9.dtb \
    uImage-imx6q-ts4900-a.dtb:imx6q-ts4900-a.dtb \
    uImage-imx6dl-ts4900-a.dtb:imx6dl-ts4900-a.dtb \
    uImage-imx6q-ts4900-14.dtb:imx6q-ts4900-14.dtb \
    uImage-imx6dl-ts4900-14.dtb:imx6dl-ts4900-14.dtb \
    uImage-imx6q-ts7970.dtb:imx6q-ts7970.dtb \
    uImage-imx6dl-ts7970.dtb:imx6dl-ts7970.dtb \
    ts4900-fpga.bin:ts4900-fpga.bin \
    "
