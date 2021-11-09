SUMMARY = "Utilities for signing UEFI binaries for use with secure boot"

LICENSE = "GPLv3"

LIC_FILES_CHKSUM = "\
    file://LICENSE.GPLv3;md5=9eef91148a9b14ec7f9df333daebc746 \
    file://COPYING;md5=a7710ac18adec371b84a9594ed04fd20 \
"

DEPENDS += "binutils openssl gnu-efi gnu-efi-native util-linux"
DEPENDS += "binutils-native help2man-native coreutils-native openssl-native util-linux-native"

SRC_URI = " \
    git://git.kernel.org/pub/scm/linux/kernel/git/jejb/sbsigntools.git;protocol=https;name=sbsigntools \
    git://github.com/rustyrussell/ccan.git;protocol=https;destsuffix=git/lib/ccan.git;name=ccan \
    file://0001-configure-Dont-t-check-for-gnu-efi.patch \
    file://0002-docs-Don-t-build-man-pages.patch \
    file://0003-sbsign-add-x-option-to-avoid-overwrite-existing-sign.patch  \
    file://0001-src-Makefile.am-Add-read_write_all.c-to-common_SOURC.patch \
    file://0001-fileio.c-initialize-local-variables-before-use-in-fu.patch \
    file://0001-Makefile.am-do-not-use-Werror.patch \
    file://0001-Fix-openssl-3.0-issue-involving-ASN1-xxx_it.patch \
"
SRCREV_sbsigntools  ?= "f12484869c9590682ac3253d583bf59b890bb826"
SRCREV_ccan         ?= "b1f28e17227f2320d07fe052a8a48942fe17caa5"
SRCREV_FORMAT       =  "sbsigntools_ccan"

PV = "0.9.4-git${SRCPV}"

S = "${WORKDIR}/git"

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

do_configure:prepend() {
    cd ${S}

    if [ ! -e lib/ccan ]; then

        # Use empty SCOREDIR because 'make scores' is not run.
        # The default setting depends on (non-whitelisted) host tools.
        sed -i -e 's#^\(SCOREDIR=\).*#\1#' lib/ccan.git/Makefile

        TMPDIR=lib lib/ccan.git/tools/create-ccan-tree \
            --build-type=automake lib/ccan \
            talloc read_write_all build_assert array_size endian
    fi

    # Create generatable docs from git
    (
    echo "Authors of sbsigntool:"
    echo
    git log --format='%an' | sort -u | sed 's,^,\t,'
    ) > AUTHORS

    # Generate simple ChangeLog
    git log --date=short --format='%ad %t %an <%ae>%n%n  * %s%n' > ChangeLog
    
    cd ${B}
}

BBCLASSEXTEND = "native nativesdk"
