# Don't trigger in the kernel image without initramfs
# Boards should:
# a) use kernel-image-initramfs and deploy in in the rootfs (ex bbb)
# b) use boot deployment using BALENA_BOOT_PARTITION_FILES mechanism to deploy
#    the initramfs bundled kernel image
python __anonymous() {
    kernel_image_type = d.getVar('KERNEL_IMAGETYPE')
    kernel_package_name = d.getVar('KERNEL_PACKAGE_NAME') or "kernel"
    d.appendVar('PACKAGE_EXCLUDE',
                ' %s-image-%s-*' % (kernel_package_name, kernel_image_type.lower()))
}
