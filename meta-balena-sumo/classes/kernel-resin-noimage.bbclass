# Don't trigger in the kernel image without initramfs
# Boards should:
# a) use kernel-image-initramfs and deploy in in the rootfs (ex bbb)
# b) use boot deployment using RESIN_BOOT_PARTITION_FILES mechanism to deploy
#    the initramfs bundled kernel image
RDEPENDS_${KERNEL_PACKAGE_NAME}-base = ""
