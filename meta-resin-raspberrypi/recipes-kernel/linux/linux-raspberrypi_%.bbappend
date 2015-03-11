# Check http://www.openembedded.org/wiki/Styleguide for why the following line has abominated quotes.
# The append function just appens to the text of the SRC_URI and if any other reciped appends to this we need to have
# a trailing slash to prevent errors.

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
	kernel_configure_variable CGROUP_FREEZER y
	kernel_configure_variable CGROUP_PERF y
	kernel_configure_variable CPUSETS y
	kernel_configure_variable PROC_PID_CPUSET y
	kernel_configure_variable MEMCG y
	kernel_configure_variable MEMCG_SWAP y
	kernel_configure_variable MEMCG_SWAP_ENABLED y
	kernel_configure_variable RESOURCE_COUNTERS y
	kernel_configure_variable VETH y
	kernel_configure_variable MACVLAN y
	kernel_configure_variable VLAN_8021Q y
	kernel_configure_variable POSIX_MQUEUE y
	kernel_configure_variable NETFILTER_XT_MATCH_ADDRTYPE y
	kernel_configure_variable NETFILTER_XT_MATCH_CONNTRACK y
	kernel_configure_variable BTRFS_FS y
	kernel_configure_variable TUN y
	kernel_configure_variable IPV6 y
	kernel_configure_variable UIDGID_STRICT_TYPE_CHECKS y
	kernel_configure_variable FB_TFT m
	kernel_configure_variable FB_TFT_AGM1264K_FL m m
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
	kernel_configure_variable FB_TFT_UC1701 m
	kernel_configure_variable FB_TFT_UPD161704 m
	kernel_configure_variable FB_TFT_WATTEROTT m
	kernel_configure_variable FB_FLEX m
	kernel_configure_variable FB_TFT_FBTFT_DEVICE m
}
