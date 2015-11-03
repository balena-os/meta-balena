FILESEXTRAPATHS_prepend := "${THISDIR}/linux-raspberrypi-4.1:"

# Support for FT6X06 capacitive touchscreen
# Patches from: https://github.com/adafruit/adafruit-raspberrypi-linux/tree/rpi-4.1.y
# This doesn't work yet as there is no i2c support in the staging fbtft_device
FT6X06_PATCHES = "\
    file://0001-add-first-round-captouch-support.patch \
    file://0002-ok-at-least-loading-with-a-kernel-DTO-now.patch \
    file://0003-SDL-TS-and-no-debug-output-works.patch \
    file://0004-ft6x06_ts-switch-from-resume-suspend-to-device-point.patch \
    file://0005-ft6x06_ts-move-suspend-resume-into-driver-portion-of.patch \
    file://0006-ft6x06-s-drv-dev.patch \
    "
SRC_URI += "${FT6X06_PATCHES}"

RESIN_CONFIGS_append = " ft6x06"
RESIN_CONFIGS[ft6x06] = " \
   CONFIG_TOUCHSCREEN_FT6X06=m \
   "

# Overlay for the RPI 7" DSI display
KERNEL_DEVICETREE_append = " overlays/rpi-ft5406-overlay.dtb"
