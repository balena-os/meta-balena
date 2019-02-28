SUMMARY = "Linux kernel modules headers"
DESCRIPTION = "This recipe generates a kernel modules headers archive from \
the linux kernel source. The headers are needed for OOT module building \
and are taking up less space than the entire linux kernel source tree. \
"
SECTION = "devel/kernel"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=89aea4e17d99a7cacdbeed46a0096b10"

DEPENDS += " \
    virtual/kernel \
    bc-native \
    bison-native \
    openssl \
    openssl-native \
    util-linux-native \
    elfutils-native \
    util-linux \
    elfutils \
    "

SRC_URI = "git://github.com/resin-os/module-headers.git;protocol=https"

SRCREV = "v0.0.14"

S = "${WORKDIR}/git"
B = "${WORKDIR}"

inherit deploy kernel-arch

HOSTCC = "${BUILD_CC} ${BUILD_CFLAGS} ${BUILD_LDFLAGS}"

do_configure[noexec] = "1"

do_compile() {
    mkdir -p kernel_modules_headers
    ${S}/gen_mod_headers ./kernel_modules_headers ${STAGING_KERNEL_DIR} ${DEPLOY_DIR_IMAGE} ${ARCH} ${TARGET_PREFIX} "${CC}" "${HOSTCC}"

    # Sanity test

    file_output=$(find kernel_modules_headers/  | xargs file | grep ELF)
    echo "$file_output" | while read -r a; do
        if echo "$a" | grep -Fiq "sysroot" ; then
            bbwarn "$a"
            bbwarn "Sysroot keyword found in interpreter ELF files"
            exit 1
        fi
    done

    tar -czf ${B}/kernel_modules_headers.tar.gz kernel_modules_headers
}

do_install() {
    install -d ${D}/usr/src/kernel-hdrs
    cd kernel_modules_headers
    find . -type f -exec install -D "{}" "${D}/usr/src/kernel-hdrs/{}" \;
}

do_deploy() {
    cp ${B}/kernel_modules_headers.tar.gz ${DEPLOYDIR}
    rm -rf ${B}/kernel_modules_headers
}

do_compile[depends] += "virtual/kernel:do_deploy virtual/kernel:do_patch"
addtask deploy before do_package after do_install

PACKAGE_ARCH = "${MACHINE_ARCH}"
FILES_${PN} += "/usr/src/*"

# Tools inside the headers package are slightly special.
# Skip some QA checks. We are interested in the arch check only.
INSANE_SKIP_${PN} = "file-rdeps ldflags staticdev already-stripped"
