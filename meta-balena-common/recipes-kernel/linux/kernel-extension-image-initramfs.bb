require recipes-kernel/linux/kernel-image-initramfs.bb

KERNEL_INITRAMFS_PROVIDER = "virtual/kernel-extension"
KERNEL_INITRAMFS_DEPLOY_DIR = "${KERNEL_EXTENSION_DEPLOY_DIR}"
