SUMMARY = "Tools to support reading and manipulating the UEFI signature database"
DESCRIPTION = "\
From the EFI Tools package in the Linux user-space, it's now possible \
to read and manipulate the UEFI signatures database via the new \
efi-readvar and efi-updatevar commands. Aside from needing efitools \
1.4, the EFIVARFS file-system is also needed, which was only introduced \
in the Linux 3.8 kernel. \
"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=e28f66b16cb46be47b20a4cdfe6e99a1"

DEPENDS:append = " \
    help2man-native openssl-native sbsigntool-native \
    libfile-slurp-perl-native \
"

PV = "1.9.2+git${SRCPV}"

SRC_URI = "\
    git://git.kernel.org/pub/scm/linux/kernel/git/jejb/efitools.git;branch=master \
    file://Fix-for-the-cross-compilation.patch \
    file://Kill-all-the-build-warning-caused-by-implicit-declar.patch \
    file://Fix-the-wrong-dependency-for-blacklist.esl.patch \
    file://LockDown-run-system-warm-reset-after-the-key-provisi.patch \
    file://Allow-to-override-tools-for-target-build.patch \
    file://Fix-help2man-failure.patch \
    file://Don-t-build-PreLoader.efi.patch \
    file://Reuse-xxdi.pl.patch \
    file://Add-static-keyword-for-IsValidVariableHeader.patch \
    file://Dynamically-load-openssl.cnf-for-openssl-1.0.x-1.1.x.patch \
    file://0001-console.c-Fix-compilation-against-latest-usr-include.patch \
    file://0001-console-Fix-a-typo-in-the-EFI-warning-list-in-gnu-ef.patch \
"
SRCREV = "392836a46ce3c92b55dc88a1aebbcfdfc5dcddce"

PARALLEL_MAKE = ""

S = "${WORKDIR}/git"

inherit perlnative

EXTRA_OEMAKE = "\
    HELP2MAN='${STAGING_BINDIR_NATIVE}/help2man' \
    OPENSSL='${STAGING_BINDIR_NATIVE}/openssl' \
    SBSIGN='${STAGING_BINDIR_NATIVE}/sbsign' \
    NM='${NM}' AR='${AR}' OBJCOPY='${OBJCOPY}' \
    OPENSSL_LIB='${STAGING_LIBDIR_NATIVE}' \
    EXTRA_LDFLAGS='${LDFLAGS}' \
"
EXTRA_OEMAKE:append:x86 = " ARCH=ia32"
EXTRA_OEMAKE:append:x86-64 = " ARCH=x86_64"
EXTRA_OEMAKE:append:arm = "ARCH=arm"
EXTRA_OEMAKE:append:aarch64 = " ARCH=aarch64"

EFI_BOOT_PATH = "/boot/efi/EFI/BOOT"

do_compile:prepend() {
    sed -i -e "1s:#!.*:#!/usr/bin/env nativeperl:" xxdi.pl 
}

do_install() {
    oe_runmake install DESTDIR='${D}${base_prefix}'
}

FILES:${PN} += "${EFI_BOOT_PATH}"

SSTATE_ALLOW_OVERLAP_FILES += "${DEPLOY_DIR_IMAGE}/LockDown.efi"
