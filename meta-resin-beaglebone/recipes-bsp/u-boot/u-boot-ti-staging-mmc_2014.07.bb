require recipes-bsp/u-boot/u-boot-ti-staging_2014.07.bb

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += "file://beaglebone_MMC_ENV_DISABLE.patch"

UBOOT_IMAGE = "u-boot-mmc-${MACHINE}-${PV}-${PR}.${UBOOT_SUFFIX}"
UBOOT_BINARY = "u-boot-mmc.${UBOOT_SUFFIX}"
UBOOT_SYMLINK = "u-boot-mmc-${MACHINE}.${UBOOT_SUFFIX}"
SPL_UART_BINARY = ""
PKG_${PN} = "u-boot-mmc"
PKG_${PN}-dev = "u-boot-mmc-dev"
PKG_${PN}-dbg = "u-boot-mmc-dbg"

PROVIDES = "u-boot-mmc"

do_compile_append () {
	cp u-boot.img ${UBOOT_BINARY}
}

do_install () {
	#Dont install this package at all
}

do_deploy () {
	install -d ${DEPLOYDIR}
	install ${S}/${UBOOT_BINARY} ${DEPLOYDIR}/${UBOOT_IMAGE}

	cd ${DEPLOYDIR}
	rm -f ${UBOOT_SYMLINK}
	ln -sf ${UBOOT_IMAGE} ${UBOOT_SYMLINK}
}

do_populate_sysroot () {
	echo "Do Nothing"
}

do_packagedata () {
	echo "Do Nothing"
}
