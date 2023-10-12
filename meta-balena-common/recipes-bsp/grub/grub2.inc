SUMMARY = "GRUB2 is the next-generation GRand Unified Bootloader"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
DESCRIPTION = "GRUB2 is the next generaion of a GPLed bootloader \
intended to unify bootloading across x86 operating systems. In \
addition to loading the Linux kernel, it implements the Multiboot \
standard, which allows for flexible loading of multiple boot images."

HOMEPAGE = "http://www.gnu.org/software/grub/"
SECTION = "bootloaders"

LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504"

S = "${WORKDIR}/grub-grub-${PV}"

SRCREV_gnulib = "d0355fa5caefab3de190168424f1494b6dfe75be"

SRC_URI = "\
    https://git.savannah.gnu.org/cgit/grub.git/snapshot/grub-grub-${PV}.tar.gz \
    git://git.savannah.gnu.org/git/gnulib.git;protocol=https;branch=master;destsuffix=gnulib;name=gnulib"

SRC_URI[sha256sum] = "c3b747559d7bb3977ee663639eab9f8fa6a103a7dc3721e78aee1fb5dc808504"

DEPENDS = "flex-native bison-native gettext-native"

GRUB_COMPATIBLE_HOST = '(x86_64.*|i.86.*|arm.*|aarch64.*|riscv.*)-(linux.*|freebsd.*)'
COMPATIBLE_HOST = "${GRUB_COMPATIBLE_HOST}"
# Grub doesn't support hard float toolchain and won't be able to forcefully
# disable it on some of the target CPUs. See 'configure.ac' for
# supported/unsupported CPUs in hardfp.
COMPATIBLE_HOST:armv7a = "${@'null' if bb.utils.contains('TUNE_CCARGS_MFLOAT', 'hard', True, False, d) else d.getVar('GRUB_COMPATIBLE_HOST')}"
COMPATIBLE_HOST:armv7ve = "${@'null' if bb.utils.contains('TUNE_CCARGS_MFLOAT', 'hard', True, False, d) else d.getVar('GRUB_COMPATIBLE_HOST')}"

# configure.ac has code to set this automagically from the target tuple
# but the OE freeform one (core2-foo-bar-linux) don't work with that.

GRUBPLATFORM:arm = "efi"
GRUBPLATFORM:aarch64 = "efi"
GRUBPLATFORM:riscv32 = "efi"
GRUBPLATFORM:riscv64 = "efi"
GRUBPLATFORM ??= "pc"

inherit autotools gettext texinfo pkgconfig

CFLAGS:remove = "-O2"

EXTRA_OECONF = "--with-platform=${GRUBPLATFORM} \
                --disable-grub-mkfont \
                --program-prefix="" \
                --enable-liblzma=no \
                --enable-libzfs=no \
                --enable-largefile \
                --disable-werror \
"

PACKAGECONFIG ??= ""
PACKAGECONFIG[grub-mount] = "--enable-grub-mount,--disable-grub-mount,fuse"
PACKAGECONFIG[device-mapper] = "--enable-device-mapper,--disable-device-mapper,libdevmapper"

# grub2 creates its own set of -nostdinc / -isystem / -ffreestanding CFLAGS and
# OE's default BUILD_CFLAGS (assigned to CFLAGS for native builds) etc, conflict
# with that. Note that since BUILD_CFLAGS etc are not used by grub2 target
# builds, it's safe to clear them unconditionally for both target and native.
BUILD_CPPFLAGS = ""
BUILD_CFLAGS = ""
BUILD_CXXFLAGS = ""
BUILD_LDFLAGS = ""

export PYTHON = "python3"

do_configure:prepend() {
	cd ${S}
        ./bootstrap --gnulib-srcdir="${WORKDIR}/gnulib" \
                    --no-git
	FROM_BOOTSTRAP=1 ${S}/autogen.sh
	cd ${B}
}
