# Pre warrior busybox didn't have bc
RDEPENDS_initramfs-module-resindataexpander_append = " bc"
RDEPENDS_initramfs-module-kexec = " \
    kexec-tools \
    util-linux \
    "
