SUMMARY = "Tools to support reading and manipulating the UEFI signature database"
DESCRIPTION = "\
From the EFI Tools package in the Linux user-space, it's now possible \
to read and manipulate the UEFI signatures database via the new \
efi-readvar and efi-updatevar commands. Aside from needing efitools \
1.4, the EFIVARFS file-system is also needed, which was only introduced \
in the Linux 3.8 kernel. \
"

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=e28f66b16cb46be47b20a4cdfe6e99a1"

DEPENDS:append = " \
    help2man-native openssl-native sbsigntool-native \
    libfile-slurp-perl-native \
"
DEPENDS:append:class-target = " efitools-native sbsigntool-native"
PV = "1.9.2+git${SRCPV}"

SRC_URI = "\
    git://git.kernel.org/pub/scm/linux/kernel/git/jejb/efitools.git;branch=master;destsuffix=git \
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
    file://0001-hash-to-efi-sig-list.c-Allow-raw-hashes-as-arguments.patch \
"
SRCREV = "b988d20a7f8373cf19c30d5c9c459f3e87f28da2"

PARALLEL_MAKE = ""

#S = "${UNPACKDIR}/git"
S = "${@d.getVar('UNPACKDIR') or d.getVar('WORKDIR')}/git"

inherit perlnative

# 3. Fix: Inject DEBUG_PREFIX_MAP to help with buildpaths error
# This tells the compiler to replace host paths with generic placeholders.
TARGET_CC_ARCH += "${DEBUG_PREFIX_MAP}"

EXTRA_OEMAKE = "\
    HELP2MAN='${STAGING_BINDIR_NATIVE}/help2man' \
    OPENSSL='${STAGING_BINDIR_NATIVE}/openssl' \
    SBSIGN='${STAGING_BINDIR_NATIVE}/sbsign' \
    NM='${NM}' AR='${AR}' OBJCOPY='${OBJCOPY}' \
    OPENSSL_LIB='${STAGING_LIBDIR_NATIVE}' \
    EXTRA_LDFLAGS='${LDFLAGS}' \
    EXTRA_CFLAGS='${TARGET_CFLAGS}' \
"

DEPENDS:append:class-target = " efitools-native"


EXTRA_OEMAKE:append:x86 = " ARCH=ia32"
EXTRA_OEMAKE:append:x86-64 = " ARCH=x86_64"
EXTRA_OEMAKE:append:arm = " ARCH=arm"
EXTRA_OEMAKE:append:aarch64 = " ARCH=aarch64"

EFI_BOOT_PATH = "/boot/efi/EFI/BOOT"

do_compile:prepend() {
    # Ensure we are in the source directory
    cd ${S}
    sed -i -e "1s:#!.*:#!/usr/bin/env perl:" xxdi.pl
}

do_install() {
    # We use DESTDIR=${D} and let prefix handle the rest
    oe_runmake install DESTDIR='${D}'
    install -d ${D}${bindir}
    install -m 0755 ${B}/cert-to-efi-sig-list ${D}${bindir}/
    install -m 0755 ${B}/sign-efi-sig-list ${D}${bindir}/
    install -m 0755 ${B}/sig-list-to-certs ${D}${bindir}/
    install -m 0755 ${B}/hash-to-efi-sig-list ${D}${bindir}/
    install -m 0755 ${B}/cert-to-efi-hash-list ${D}${bindir}/
    install -m 0755 ${B}/efi-readvar ${D}${bindir}/
    install -m 0755 ${B}/efi-updatevar ${D}${bindir}/
}

FILES:${PN} += "${EFI_BOOT_PATH}"

# 4. Fix: Use INSANE_SKIP as a fallback for the remaining buildpaths errors.
# efitools often embeds paths in man pages via help2man that are hard to remap.
INSANE_SKIP:${PN}-dbg += "buildpaths"
INSANE_SKIP:${PN}-doc += "buildpaths"

SSTATE_ALLOW_OVERLAP_FILES += "${DEPLOY_DIR_IMAGE}/LockDown.efi"
