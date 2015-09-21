inherit deploy

# Delopy the bitstream and don't install as we burn it in boot partition
# and not in rootfs
do_deploy () {
    install -d ${DEPLOYDIR}
    install -m 0755 ${WORKDIR}/ts4900-fpga.bin ${DEPLOYDIR}/
}
addtask deploy after do_install before do_build
do_install[noexec] = "1"

PACKAGE_ARCH = "${MACHINE_ARCH}"
