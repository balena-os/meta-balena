inherit kernel kernel-resin
require recipes-kernel/linux/linux-yocto.inc

SUMMARY = "Linux kernel for TS Marvell Boards"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

KBRANCH = "linux-3.14-pxa16x"
SRCREV = "b8e31bb343585cea8516bc8b55a74b8bc20fa294"

SRC_URI = " \
    git://github.com/embeddedarm/linux-3.14-pxa16x.git;branch=${KBRANCH} \
    file://defconfig \
    file://initramfs.cpio \
    "

COMPATIBLE_MACHINE = "ts7700"
