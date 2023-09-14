# Pre warrior busybox didn't have bc
RDEPENDS_initramfs-module-resindataexpander_append = " bc"
RDEPENDS_initramfs-module-kexec = " \
    kexec-tools \
    util-linux \
    "
RDEPENDS_initramfs-module-migrate = " \
    util-linux \
    resin-init-flasher \
    bash \
    balena-config-vars-config \
    "
RDEPENDS_initramfs-module-recovery = "${PN}-base android-tools"
