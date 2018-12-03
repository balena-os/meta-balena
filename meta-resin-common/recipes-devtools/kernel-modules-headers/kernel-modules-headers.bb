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
    util-linux-native \
    elfutils-native \
    util-linux \
    elfutils \
    "

SRC_URI = "git://github.com/resin-os/module-headers.git;protocol=https"

SRCREV = "v0.0.12"

S = "${WORKDIR}/git"
B = "${WORKDIR}"

inherit deploy kernel-arch

HOSTCC = "${BUILD_CC} ${BUILD_CFLAGS} ${BUILD_LDFLAGS}"

do_configure[noexec] = "1"

do_compile() {
    mkdir -p kernel_modules_headers
    ${S}/gen_mod_headers ./kernel_modules_headers ${STAGING_KERNEL_DIR} ${DEPLOY_DIR_IMAGE} ${ARCH} ${TARGET_PREFIX} "${CC}" "${HOSTCC}"

    # Sanity test
    test_arch=$(find kernel_modules_headers/  | xargs file | grep ELF | xargs -I a bash -c 'if ! echo "a" | grep -Fiq "${ARCH}" ; then echo "Did not find ${ARCH}"; fi')
    if [ ! -z "$test_arch" ]; then
        bberror "Wrong arch found in ELF files"
    fi
    test_interpreter=$(find kernel_modules_headers/  | xargs file | grep ELF | xargs -I a bash -c 'if echo "a" | grep -Fiq "sysroot" ; then echo "Found sysroot in interpreter" ; fi')
    if [ ! -z "$test_interpreter" ]; then
        bberror "Sysroot keyword found in interpreter ELF files"
    fi

    tar -czf kernel_modules_headers.tar.gz kernel_modules_headers
    rm -rf kernel_modules_headers
}

do_deploy() {
    cp kernel_modules_headers.tar.gz ${DEPLOYDIR}
}

do_compile[depends] += "virtual/kernel:do_deploy virtual/kernel:do_patch"
addtask deploy before do_package after do_install

PACKAGE_ARCH = "${MACHINE_ARCH}"
