#
# ts4900
#

IMAGE_FSTYPES_ts4900 = "resin-sdcard"

# We burn the FPGA bitstream in uboot so we need it in boot partition
RDEPENDS_${PN}_append_ts4900 = " ts4900-fpga"

# Customize resin-sdcard
RESIN_BOOT_PARTITION_FILES_ts4900 = " \
    ${KERNEL_IMAGETYPE}-${MACHINE}.bin:/boot/${KERNEL_IMAGETYPE} \
    uImage-imx6dl-ts4900.dtb:/boot/imx6dl-ts4900.dtb \
    uImage-imx6q-ts4900.dtb:/boot/imx6q-ts4900.dtb \
    uImage-imx6q-ts4900-2.dtb:/boot/imx6q-ts4900-2.dtb \
    uImage-imx6dl-ts4900-2.dtb:/boot/imx6dl-ts4900-2.dtb \
    uImage-imx6q-ts4900-9.dtb:/boot/imx6q-ts4900-9.dtb \
    uImage-imx6dl-ts4900-9.dtb:/boot/imx6dl-ts4900-9.dtb \
    uImage-imx6q-ts4900-a.dtb:/boot/imx6q-ts4900-a.dtb \
    uImage-imx6dl-ts4900-a.dtb:/boot/imx6dl-ts4900-a.dtb \
    uImage-imx6q-ts4900-14.dtb:/boot/imx6q-ts4900-14.dtb \
    uImage-imx6dl-ts4900-14.dtb:/boot/imx6dl-ts4900-14.dtb \
    uImage-imx6q-ts7970.dtb:/boot/imx6q-ts7970.dtb \
    uImage-imx6dl-ts7970.dtb:/boot/imx6dl-ts7970.dtb \
    ts4900-fpga.bin:/boot/ts4900-fpga.bin \
    "
