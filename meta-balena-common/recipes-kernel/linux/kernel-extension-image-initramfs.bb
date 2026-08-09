require recipes-kernel/linux/kernel-image-initramfs.bb

KERNEL_INITRAMFS_PROVIDER = "virtual/kernel-extension"
KERNEL_INITRAMFS_DEPLOY_DIR = "${DEPLOY_DIR_IMAGE}/kernel-extension"
