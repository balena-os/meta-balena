SUMMARY = "Linux kernel modules headers"
DESCRIPTION = "This recipe generates a kernel modules headers archive from \
the linux kernel source. The headers are needed for OOT module building \
and are taking up less space than the entire linux kernel source tree. \
"
SECTION = "devel/kernel"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=89aea4e17d99a7cacdbeed46a0096b10"

DEPENDS = "virtual/kernel"

SRC_URI = "git://github.com/resin-os/module-headers.git;protocol=https"

SRCREV = "73ee06f5133f9658f691f0c385b1c3e794e6bdd3"

S = "${WORKDIR}/git"
B = "${WORKDIR}"

inherit deploy

do_patch[noexec] = "1"

do_configure[noexec] = "1"

do_compile() {
    mkdir -p kernel_modules_headers
    cp -n ${STAGING_KERNEL_BUILDDIR}/.config ${STAGING_KERNEL_BUILDDIR}/Module.symvers ${STAGING_KERNEL_DIR}
    if [ "${TRANSLATED_TARGET_ARCH}" = "x86-64" ] || [ "${TRANSLATED_TARGET_ARCH}" = "i686" ]; then
        TGT_ARCH="x86"
    else
        TGT_ARCH=${TRANSLATED_TARGET_ARCH}
    fi
    ${S}/gen_mod_headers ${STAGING_KERNEL_DIR} kernel_modules_headers ${TGT_ARCH} ARCH=${TGT_ARCH} CROSS_COMPILE=${TARGET_PREFIX}
    tar -cjf kernel_modules_headers.tar.bz2 kernel_modules_headers
    rm -rf kernel_modules_headers
}

do_deploy() {
    cp kernel_modules_headers.tar.bz2 ${DEPLOYDIR}
}

addtask deploy before do_package after do_install

PACKAGE_ARCH = "${MACHINE_ARCH}"
