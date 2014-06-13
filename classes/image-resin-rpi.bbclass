inherit image_types

IMAGE_TYPEDEP_resin-noobs = "${SDIMG_ROOTFS_TYPE}"


# Use an tar.xz by default as rootfs
SDIMG_ROOTFS_TYPE ?= "tar"
SDIMG_ROOTFS = "${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.${SDIMG_ROOTFS_TYPE}"

IMAGE_DEPENDS_resin-noobs = " \
			virtual/kernel \
			bcm2835-bootfiles \
			noobs \
			"

# BOOT TAR name
BOOT_TAR_forcevariable  = "${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.boot.tar"


IMAGEDATESTAMP = "${@time.strftime('%Y.%m.%d',time.gmtime())}"

IMAGE_CMD_resin-noobs () {

	export BOOT_WORK=${WORKDIR}/${IMAGE_NAME}.boot
	rm -rf ${BOOT_WORK}
	mkdir -p ${BOOT_WORK}

	cp -r ${DEPLOY_DIR_IMAGE}/bcm2835-bootfiles/* ${BOOT_WORK}/
	cp ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-${MACHINE}.bin ${BOOT_WORK}/kernel.img
	
	sed -i 's/\/dev\/mmcblk0p2/@ROOT@/g' ${BOOT_WORK}/cmdline.txt	
	# Add stamp file
	echo "${IMAGE_NAME}-${IMAGEDATESTAMP}" > ${BOOT_WORK}/image-version-info

	tar -cf ${BOOT_TAR} -C ${BOOT_WORK} .
	xz -9 -e ${BOOT_TAR}
	ln -sf ${BOOT_TAR}.xz ${DEPLOY_DIR_IMAGE}/boot.tar.xz

	cp ${DEPLOY_DIR_IMAGE}/boot.tar.xz ${DEPLOY_DIR_IMAGE}/noobs/os/Resin
	tar --delete -f ${DEPLOY_DIR_IMAGE}/resin-rpi-raspberrypi.tar --wildcards ./boot/*
	rm ${DEPLOY_DIR_IMAGE}/noobs/os/Resin/root.tar.xz
	cp  ${DEPLOY_DIR_IMAGE}/resin-rpi-raspberrypi.tar ${DEPLOY_DIR_IMAGE}/noobs/os/Resin/root.tar
	xz -9 -e ${DEPLOY_DIR_IMAGE}/noobs/os/Resin/root.tar

	

}

ROOTFS_POSTPROCESS_COMMAND += " resin_rpi_generate_sysctl_config ; "

resin_rpi_generate_sysctl_config() {
	# systemd sysctl config
	test -d ${IMAGE_ROOTFS}${sysconfdir}/sysctl.d && \
		echo "vm.min_free_kbytes = 8192" > ${IMAGE_ROOTFS}${sysconfdir}/sysctl.d/rpi-vm.conf

	# sysv sysctl config
	IMAGE_SYSCTL_CONF="${IMAGE_ROOTFS}${sysconfdir}/sysctl.conf"
	test -e ${IMAGE_ROOTFS}${sysconfdir}/sysctl.conf && \
		sed -e "/vm.min_free_kbytes/d" -i ${IMAGE_SYSCTL_CONF}
	echo "" >> ${IMAGE_SYSCTL_CONF} && echo "vm.min_free_kbytes = 8192" >> ${IMAGE_SYSCTL_CONF}
}
