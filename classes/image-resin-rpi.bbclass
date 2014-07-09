inherit image_types


IMAGE_TYPEDEP_resin-noobs = "${SDIMG_ROOTFS_TYPE}"
IMAGE_TYPEDEP_resin-noobs-dev = "${SDIMG_ROOTFS_TYPE}"

# Use an tar.xz by default as rootfs
SDIMG_ROOTFS_TYPE ?= "tar"
SDIMG_ROOTFS = "${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.${SDIMG_ROOTFS_TYPE}"

IMAGE_DEPENDS_resin-noobs = " \
			virtual/kernel \
			bcm2835-bootfiles \
			rpi-init \
			noobs \
			"

IMAGE_DEPENDS_resin-noobs-dev = " \
			virtual/kernel \
			bcm2835-bootfiles \
			rpi-init \
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

	## Overwrite the cmdline.txt
	echo "dwc_otg.lpm_enable=0 console=tty1 root=@ROOT@ rootfstype=ext4 rootwait quiet elevator=deadline" > ${BOOT_WORK}/cmdline.txt

	# Add stamp file
	echo "${IMAGE_NAME}-${IMAGEDATESTAMP}" > ${BOOT_WORK}/image-version-info

	# Add camera module support
	echo start_file=start_x.elf >> ${BOOT_WORK}/config.txt
	echo fixup_file=fixup_x.dat >> ${BOOT_WORK}/config.txt

	tar -cf ${BOOT_TAR} -C ${BOOT_WORK} .
	xz -9 -e ${BOOT_TAR}
	ln -sf ${BOOT_TAR}.xz ${DEPLOY_DIR_IMAGE}/boot.tar.xz

	cp ${DEPLOY_DIR_IMAGE}/boot.tar.xz ${DEPLOY_DIR_IMAGE}/noobs/os/Resin
	tar --delete -f ${DEPLOY_DIR_IMAGE}/resin-rpi-raspberrypi.tar --wildcards ./boot/*
	rm -rf ${DEPLOY_DIR_IMAGE}/noobs/os/Resin/root.tar.xz
	cp  ${DEPLOY_DIR_IMAGE}/resin-rpi-raspberrypi.tar ${DEPLOY_DIR_IMAGE}/noobs/os/Resin/root.tar
	xz -9 -e ${DEPLOY_DIR_IMAGE}/noobs/os/Resin/root.tar



}

IMAGE_CMD_resin-noobs-dev () {

	export BOOT_WORK=${WORKDIR}/${IMAGE_NAME}.boot
	rm -rf ${BOOT_WORK}
	mkdir -p ${BOOT_WORK}

	cp -r ${DEPLOY_DIR_IMAGE}/bcm2835-bootfiles/* ${BOOT_WORK}/
	cp ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-${MACHINE}.bin ${BOOT_WORK}/kernel.img

	# Add camera module support
	echo start_file=start_x.elf >> ${BOOT_WORK}/config.txt
	echo fixup_file=fixup_x.dat >> ${BOOT_WORK}/config.txt

	## Overwrite the cmdline.txt
	echo "dwc_otg.lpm_enable=0 console=ttyAMA0,115200 kgdboc=ttyAMA0,115200 root=@ROOT@ rootfstype=ext4 elevator=deadline rootwait debug" > ${BOOT_WORK}/cmdline.txt

	# Add stamp file
	echo "${IMAGE_NAME}-${IMAGEDATESTAMP}" > ${BOOT_WORK}/image-version-info

	tar -cf ${BOOT_TAR} -C ${BOOT_WORK} .
	xz -9 -e ${BOOT_TAR}
	ln -sf ${BOOT_TAR}.xz ${DEPLOY_DIR_IMAGE}/boot.tar.xz

	cp ${DEPLOY_DIR_IMAGE}/boot.tar.xz ${DEPLOY_DIR_IMAGE}/noobs/os/Resin
	tar --delete -f ${DEPLOY_DIR_IMAGE}/resin-rpi-dev-raspberrypi.tar --wildcards ./boot/*
	rm -rf ${DEPLOY_DIR_IMAGE}/noobs/os/Resin/root.tar.xz
	cp  ${DEPLOY_DIR_IMAGE}/resin-rpi-dev-raspberrypi.tar ${DEPLOY_DIR_IMAGE}/noobs/os/Resin/root.tar
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
