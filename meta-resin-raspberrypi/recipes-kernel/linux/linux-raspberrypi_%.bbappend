FILESEXTRAPATHS_prepend := "${THISDIR}/linux-raspberrypi:"
SRC_URI += "file://0001-Disable-rtl8192cu-and-Enable-rtlwifi.patch \
          "
FBTFT_SRCREV = "bcb4de90206842831bd40b20c93aa3e5c9553ea1"
SRC_URI_append = " https://github.com/notro/fbtft/archive/${FBTFT_SRCREV}.zip;name=fbtft"
SRC_URI[fbtft.md5sum] = "d5572f33fb9c901ea78f76ade8a234c6"
SRC_URI[fbtft.sha256sum] = "66c96130c7f4af2edac603fa30ec34371562bd1d6f8864b3f3fff004074c8985"

do_configure_prepend() {
	if [ ! -e ${S}/.fbtft_configured ]; then
		cp -r ${WORKDIR}/fbtft-${FBTFT_SRCREV} ${S}/drivers/video/fbdev/fbtft
		echo 'source "drivers/video/fbdev/fbtft/Kconfig"' >> ${S}/drivers/video/fbdev/Kconfig
		echo 'obj-y += fbtft/' >> ${S}/drivers/video/fbdev/Makefile
		touch ${S}/.fbtft_configured
	fi
}

inherit kernel-resin

RESIN_CONFIGS_append = " fbtft"
RESIN_CONFIGS[fbtft] = " \
    CONFIG_FB_TFT=m \
    CONFIG_FB_TFT_AGM1264K_FL=m \
    CONFIG_FB_TFT_BD663474=m \
    CONFIG_FB_TFT_HX8340BN=m \
    CONFIG_FB_TFT_HX8347D=m \
    CONFIG_FB_TFT_HX8353D=m \
    CONFIG_FB_TFT_ILI9320=m \
    CONFIG_FB_TFT_ILI9325=m \
    CONFIG_FB_TFT_ILI9340=m \
    CONFIG_FB_TFT_ILI9341=m \
    CONFIG_FB_TFT_ILI9481=m \
    CONFIG_FB_TFT_ILI9486=m \
    CONFIG_FB_TFT_PCD8544=m \
    CONFIG_FB_TFT_RA8875=m \
    CONFIG_FB_TFT_S6D02A1=m \
    CONFIG_FB_TFT_S6D1121=m \
    CONFIG_FB_TFT_SSD1289=m \
    CONFIG_FB_TFT_SSD1306=m \
    CONFIG_FB_TFT_SSD1331=m \
    CONFIG_FB_TFT_SSD1351=m \
    CONFIG_FB_TFT_ST7735R=m \
    CONFIG_FB_TFT_TINYLCD=m \
    CONFIG_FB_TFT_TLS8204=m \
    CONFIG_FB_TFT_UC1701=m \
    CONFIG_FB_TFT_UPD161704=m \
    CONFIG_FB_TFT_WATTEROTT=m \
    CONFIG_FB_FLEX=m \
    CONFIG_FB_TFT_FBTFT_DEVICE=m \
    "
