# Pre warrior busybox didn't have bc
RDEPENDS_initramfs-module-resindataexpander_append = " bc"
RDEPENDS_initramfs-module-recovery = "${PN}-base android-tools"
