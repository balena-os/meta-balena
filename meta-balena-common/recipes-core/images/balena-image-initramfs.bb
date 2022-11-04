DESCRIPTION = "Small image capable of booting a device. The kernel includes \
the Minimal RAM-based Initial Root Filesystem (initramfs), which finds the \
first 'init' program more efficiently. This is used to prepare the rootfs \
with some key operations."

PACKAGE_INSTALL = " \
    base-passwd \
    busybox \
    glibc-gconv \
    glibc-gconv-ibm437 \
    glibc-gconv-ibm850 \
    initramfs-module-debug \
    initramfs-module-fsuuidsinit \
    initramfs-module-prepare \
    initramfs-module-fsck \
    initramfs-module-machineid \
    initramfs-module-recovery \
    initramfs-module-resindataexpander \
    initramfs-module-rorootfs \
    initramfs-module-udev \
    initramfs-module-udevcleanup \
    initramfs-framework-base \
    udev \
    mdadm \
    ${ROOTFS_BOOTSTRAP_INSTALL} \
    "

PACKAGE_INSTALL:append = "${@oe.utils.conditional('SIGN_API','','',' initramfs-module-cryptsetup initramfs-module-kexec',d)}"
PACKAGE_INSTALL:append = "${@oe.utils.conditional('PARTITION_TABLE_TYPE','gpt',' gptfdisk ','',d)}"

# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = ""

export IMAGE_BASENAME = "balena-image-initramfs"
IMAGE_LINGUAS = ""

LICENSE = "MIT"

IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"
inherit core-image

IMAGE_ROOTFS_SIZE = "8192"
IMAGE_OVERHEAD_FACTOR = "1.0"
IMAGE_ROOTFS_EXTRA_SPACE = "0"
IMAGE_ROOTFS_MAXSIZE = "32768"


BAD_RECOMMENDATIONS += "busybox-syslog"
