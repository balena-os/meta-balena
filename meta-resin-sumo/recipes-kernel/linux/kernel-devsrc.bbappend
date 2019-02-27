# We delete the task to avoid spurious manifest and log_check warnings
deltask do_populate_sysroot

# create missing symlink for arm64 boards
do_install_prepend() {
    install -d ${D}${KERNEL_SRC_PATH}/arch/arm64/boot/dts/
    ln -sf ../../../arm/boot/dts/overlays ${D}${KERNEL_SRC_PATH}/arch/arm64/boot/dts/overlays
}
