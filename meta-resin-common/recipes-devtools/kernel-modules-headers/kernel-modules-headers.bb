SUMMARY = "Linux kernel modules headers"
DESCRIPTION = "This recipe generates a kernel modules headers archive from \
the linux kernel source. The headers are needed for OOT module building \
and are taking up less space than the entire linux kernel source tree. \
"
SECTION = "devel/kernel"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=89aea4e17d99a7cacdbeed46a0096b10"

DEPENDS = " \
    virtual/kernel \
    bc-native \
    openssl \
    openssl-native \
    "

SRC_URI = "git://github.com/resin-os/module-headers.git;protocol=https"

SRCREV = "v0.0.11"

S = "${WORKDIR}/git"
B = "${WORKDIR}"

inherit deploy kernel-arch

HOSTCC = "${BUILD_CC} ${BUILD_CFLAGS} ${BUILD_LDFLAGS}"

do_configure[noexec] = "1"

do_compile() {
    mkdir -p kernel_modules_headers
    ${S}/gen_mod_headers ./kernel_modules_headers ${STAGING_KERNEL_DIR} ${DEPLOY_DIR_IMAGE} ${ARCH} ${TARGET_PREFIX} "${HOSTCC}"
    tar -czf kernel_modules_headers.tar.gz kernel_modules_headers
    rm -rf kernel_modules_headers
}

do_deploy() {
    cp kernel_modules_headers.tar.gz ${DEPLOYDIR}
}

do_compile[depends] += "virtual/kernel:do_deploy virtual/kernel:do_patch"
addtask deploy before do_package after do_install

PACKAGE_ARCH = "${MACHINE_ARCH}"
