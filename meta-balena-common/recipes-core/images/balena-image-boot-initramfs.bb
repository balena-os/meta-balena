DESCRIPTION = "This minimal image is executed by a vendor provided bootloader. \
It contains all the BalenaOS bootloader specific features, and will kexec the \
BalenaOS initramfs"

PACKAGE_INSTALL = " \
    kexecboot \
    kexec-tools-klibc \
    kexecboot-cfg \
"

# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = ""

export IMAGE_BASENAME = "balena-image-boot-initramfs"
IMAGE_LINGUAS = ""

LICENSE = "MIT"

IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"
inherit image

IMAGE_ROOTFS_SIZE = "8192"
