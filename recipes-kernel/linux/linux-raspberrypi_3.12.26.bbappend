# Check http://www.openembedded.org/wiki/Styleguide for why the following line has abominated quotes.
# The append function just appens to the text of the SRC_URI and if any other reciped appends to this we need to have
# a trailing slash to prevent errors.
SRC_URI_append = "https://github.com/notro/fbtft/archive/32995715c7fb161bf539fefc7e250fef3599cd61.zip;name=fbtft \
           "
SRC_URI[fbtft.md5sum] = "357230a3a96cd0cfacad4adf05277a22"
SRC_URI[fbtft.sha256sum] = "a8e77512bdb7c02eafff6863f459feacd731275747ba4e94f2c0f6d7a0a1b6d4"

do_configure_prepend() {
        if [ ! -e ${S}/.fbtft_configured ]; then
            cp -r ${WORKDIR}/fbtft-32995715c7fb161bf539fefc7e250fef3599cd61 ${S}/drivers/video/fbtft
            echo 'source "drivers/video/fbtft/Kconfig"' >> ${S}/drivers/video/Kconfig
            echo 'obj-y += fbtft/' >> ${S}/drivers/video/Makefile
            touch ${S}/.fbtft_configured
        fi
}

do_configure_append(){
        kernel_configure_variable NAMESPACES y
        kernel_configure_variable UTS_NS y
        kernel_configure_variable IPC_NS y
        kernel_configure_variable PID_NS y
        kernel_configure_variable USER_NS y
        kernel_configure_variable NET_NS y
        kernel_configure_variable DEVPTS_MULTIPLE_INSTANCES y
        kernel_configure_variable CGROUP_NS y
        kernel_configure_variable CGROUP_DEVICE y
        kernel_configure_variable CGROUP_SCHED y
        kernel_configure_variable CGROUP_CPUACCT y
        kernel_configure_variable MEMCG y
        kernel_configure_variable VETH y
        kernel_configure_variable MACVLAN y
        kernel_configure_variable VLAN_8021Q y
        kernel_configure_variable POSIX_MQUEUE y
        kernel_configure_variable UIDGID_STRICT_TYPE_CHECKS y
        kernel_configure_variable FB_TFT m
        kernel_configure_variable FB_TFT_BD663474 m
        kernel_configure_variable FB_TFT_HX8340BN m
        kernel_configure_variable FB_TFT_HX8347D m
        kernel_configure_variable FB_TFT_HX8353D m
        kernel_configure_variable FB_TFT_ILI9320 m
        kernel_configure_variable FB_TFT_ILI9325 m
        kernel_configure_variable FB_TFT_ILI9340 m
        kernel_configure_variable FB_TFT_ILI9341 m
        kernel_configure_variable FB_TFT_ILI9481 m
        kernel_configure_variable FB_TFT_ILI9486 m
        kernel_configure_variable FB_TFT_PCD8544 m
        kernel_configure_variable FB_TFT_RA8875 m
        kernel_configure_variable FB_TFT_S6D02A1 m
        kernel_configure_variable FB_TFT_S6D1121 m
        kernel_configure_variable FB_TFT_SSD1289 m
        kernel_configure_variable FB_TFT_SSD1306 m
        kernel_configure_variable FB_TFT_SSD1331 m
        kernel_configure_variable FB_TFT_SSD1351 m
        kernel_configure_variable FB_TFT_ST7735R m
        kernel_configure_variable FB_TFT_TINYLCD m
        kernel_configure_variable FB_TFT_TLS8204 m
        kernel_configure_variable FB_TFT_UPD161704 m
        kernel_configure_variable FB_TFT_WATTEROTT m
        kernel_configure_variable FB_FLEX m
        kernel_configure_variable FB_TFT_FBTFT_DEVICE m
}
