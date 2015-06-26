SUMMARY = "Realtek out-of-tree kernel driver for rtl8192cu"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://include/autoconf.h;startline=1;endline=18;md5=25cbdd5262c1bef1021387c1fbe9d7ba"

inherit module

SRC_URI = "git://github.com/agherzan/rtl8192cu.git"
SRCREV = "8dc5b70d63154d85d71a213546a978393ccc2f16"
S = "${WORKDIR}/git"

EXTRA_OEMAKE += " \
    CONFIG_PLATFORM_I386_PC=n \
    KSRC=${STAGING_KERNEL_DIR} \
    "
