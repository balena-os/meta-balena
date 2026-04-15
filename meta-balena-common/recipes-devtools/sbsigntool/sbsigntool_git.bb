SUMMARY = "Utilities for signing UEFI binaries for use with secure boot"

LICENSE = "GPL-3.0-only"

LIC_FILES_CHKSUM = "\
    file://LICENSE.GPLv3;md5=9eef91148a9b14ec7f9df333daebc746 \
    file://COPYING;md5=a7710ac18adec371b84a9594ed04fd20 \
"

DEPENDS += "binutils openssl gnu-efi gnu-efi-native util-linux"
DEPENDS += "binutils-native help2man-native coreutils-native openssl-native util-linux-native"

SRC_URI = " \
    git://git.kernel.org/pub/scm/linux/kernel/git/jejb/sbsigntools.git;protocol=https;name=sbsigntools;branch=master;destsuffix=git \
    git://github.com/rustyrussell/ccan.git;protocol=https;destsuffix=git/lib/ccan.git;name=ccan;branch=master \
    file://0001-configure-Dont-t-check-for-gnu-efi.patch;striplevel=1 \
    file://0002-docs-Don-t-build-man-pages.patch;striplevel=1 \
    file://0003-sbsign-add-x-option-to-avoid-overwrite-existing-sign.patch;striplevel=1  \
    file://0001-src-Makefile.am-Add-read_write_all.c-to-common_SOURC.patch;striplevel=1 \
    file://0001-fileio.c-initialize-local-variables-before-use-in-fu.patch;striplevel=1 \
    file://0001-Makefile.am-do-not-use-Werror.patch;striplevel=1 \
    file://0001-Fix-openssl-3.0-issue-involving-ASN1-xxx_it.patch;striplevel=1 \
"
SRCREV_sbsigntools  ?= "f12484869c9590682ac3253d583bf59b890bb826"
SRCREV_ccan         ?= "b1f28e17227f2320d07fe052a8a48942fe17caa5"
SRCREV_FORMAT       =  "sbsigntools_ccan"

PV = "0.9.4-git${SRCPV}"

S = "${UNPACKDIR}/git/"

inherit autotools-brokensep pkgconfig

def efi_arch(d):
    import re
    arch = d.getVar("TARGET_ARCH")
    if re.match("i[3456789]86", arch):
        return "ia32"
    return arch

# Avoids build breaks when using no-static-libs.inc
#DISABLE_STATIC:class-target = ""

#EXTRA_OECONF:remove:class-target += "\
#    --with-libtool-sysroot \
#"

HOST_EXTRACFLAGS += "\
    INCLUDES+='-I${S}/lib/ccan.git/ \
              -I${STAGING_INCDIR_NATIVE}/efi \
              -I${STAGING_INCDIR_NATIVE} \
"

EXTRA_OEMAKE += "\
    INCLUDES='-I${S}/lib/ccan.git' \
    EFI_CPPFLAGS='-I${STAGING_INCDIR} -I${STAGING_INCDIR}/efi \
                  -I${STAGING_INCDIR}/efi/${@efi_arch(d)}' \
"

DEPENDS:append = " qemu-native"

do_configure:prepend() {
    # 1. Point QEMU to the target sysroot so it finds /lib/ld-linux-aarch64.so.1
    export QEMU_LD_PREFIX="${STAGING_DIR_TARGET}"
    
    # 2. Add the recipe-sysroot to the library path for the native probes
    export LD_LIBRARY_PATH="${STAGING_DIR_TARGET}${libdir}:${STAGING_DIR_TARGET}${base_libdir}:${LD_LIBRARY_PATH}"

    if [ ! -e ${S}/lib/ccan ]; then
        # Build the configurator natively
        ${BUILD_CC} ${BUILD_CFLAGS} ${BUILD_LDFLAGS} \
            ${S}/lib/ccan.git/tools/configurator/configurator.c \
            -o ${S}/lib/ccan.git/tools/configurator/configurator

        # Run the configurator. 
        # It will now use qemu-aarch64 (which Bitbake provides) 
        # and find the libraries thanks to QEMU_LD_PREFIX.
        ${S}/lib/ccan.git/tools/configurator/configurator ${TARGET_PREFIX}gcc \
            ${TARGET_CC_ARCH} --sysroot=${STAGING_DIR_TARGET} \
            > ${S}/lib/ccan.git/config.h

        # Create the CCAN tree
        TMPDIR=${S}/lib ${S}/lib/ccan.git/tools/create-ccan-tree \
            --build-type=automake ${S}/lib/ccan \
            talloc read_write_all build_assert array_size endian
    fi

    # Metadata generation
    git log --format='%an' | sort -u | sed 's,^,\t,' > ${S}/AUTHORS
    git log --date=short --format='%ad %t %an <%ae>%n%n  * %s%n' > ${S}/ChangeLog
}

BBCLASSEXTEND = "native nativesdk"
